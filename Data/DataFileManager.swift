//
//  DataFileManager.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A class that manages file operations for data files.
///
class DataFileManager: NSObject, NSFilePresenter {
    
    /// An enum defining the directories of the `DataFileManager`'s workspace.
    ///
    private enum Directory: String {
        case data = "Data"
        case saveFiles = "Save Files"
        case configurationFiles = "Configuration Files"
        
        /// The set of directories that do not have subdirectories of their own.
        ///
        static let leaves: Set<Directory> = [.saveFiles, .configurationFiles]
        
        /// Forms a URL for the directory.
        ///
        /// - Parameter parentUrl: The parent `URL`.
        /// - Returns: A `URL` representing the location of the directory.
        ///
        func formUrl(parentUrl: URL) -> URL {
            let url = parentUrl.appendingPathComponent(Directory.data.rawValue, isDirectory: true)
            switch self {
            case .saveFiles, .configurationFiles:
                return url.appendingPathComponent(rawValue, isDirectory: true)
            default:
                return url
            }
        }
    }
    
    /// Produces a new URL to use when managing files locally.
    ///
    private static var newLocalURL: URL {
        let bundleID = Bundle.main.bundleIdentifier!
        let appSupport = try! FileManager.default.url(for: .applicationSupportDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: true)
        return appSupport.appendingPathComponent(bundleID, isDirectory: true)
    }
    
    /// The instance of the class.
    ///
    static let instance = DataFileManager()
    
    /// The internal queue used by the manager.
    ///
    private let queue = DispatchQueue(label: "DataFileManager.queue")
    
    /// The URL to use when managing files locally.
    ///
    private var localURL: URL!
    
    /// The ubiquity token of the current user.
    ///
    private var ubiquityToken: (NSCoding & NSCopying & NSObjectProtocol)?
    
    /// The ubiquity container's URL.
    ///
    private var ubiquityURL: URL? {
        didSet {
            if let newValue = ubiquityURL, newValue != oldValue {
                presentedItemURL = Directory.data.formUrl(parentUrl: ubiquityURL!)
            } else if ubiquityURL == nil && oldValue != nil {
                presentedItemURL = nil
            }
        }
    }
    
    var presentedItemURL: URL?
    var presentedItemOperationQueue: OperationQueue
    
    private override init() {
        localURL = nil
        ubiquityToken = FileManager.default.ubiquityIdentityToken
        presentedItemURL = nil
        presentedItemOperationQueue = OperationQueue()
        super.init()
        NSFileCoordinator.addFilePresenter(self)
        
        let notificationBlock: (Notification) -> Void = { [unowned self] _ in
            let newToken = FileManager.default.ubiquityIdentityToken
            if self.ubiquityToken != nil {
                if newToken == nil {
                    // iCloud is no longer available
                    self.ubiquityToken = nil
                    self.ubiquityURL = nil
                } else if !newToken!.isEqual(self.ubiquityToken!) {
                    // iCloud user did change
                    self.ubiquityToken = newToken
                    let flag = self.createUbiquityWorkspace(); assert(flag)
                }
            } else if newToken != nil {
                // iCloud is now available
                self.ubiquityToken = newToken
                let flag = self.createUbiquityWorkspace(); assert(flag)
            }
        }
        
        NotificationCenter.default.addObserver(forName: .NSUbiquityIdentityDidChange,
                                               object: nil,
                                               queue: presentedItemOperationQueue,
                                               using: notificationBlock)
    }
    
    /// Creates a workspace at the given URL.
    ///
    /// - Parameter url: The URL at which to create the workspace.
    /// - Returns: `true` if the workspace could be created or one already exists at the provided URL,
    ///   `false` otherwise.
    ///
    private func createWorkspace(at url: URL) -> Bool {
        for leaf in Directory.leaves {
            let url = leaf.formUrl(parentUrl: url)
            do {
                try FileManager.default.createDirectory(at: url,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    case NSFileWriteFileExistsError: break // OK
                    default: return false
                    }
                }
            }
        }
        return true
    }
    
    /// Creates a workspace to manage files in the local file system.
    ///
    /// - Returns: `true` if the workspace could be created or one already exists, `false` otherwise.
    ///
    private func createLocalWorkspace() -> Bool {
        localURL = DataFileManager.newLocalURL
        return createWorkspace(at: localURL)
    }
    
    /// Creates a workspace to manage files in the ubiquity container.
    ///
    /// - Returns: `true` if the workspace could be created or one already exists, `false` otherwise.
    ///
    private func createUbiquityWorkspace() -> Bool {
        ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        return (ubiquityURL != nil) ? createWorkspace(at: ubiquityURL!) : false
    }
    
    /// Moves any files found in the given directory of the local workspace to the ubiquity container.
    ///
    /// - Parameters:
    ///   - directory: The `Directory` defining the location of the files to move.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded. The flag will be `true` only if all files could be moved.
    ///
    private func move(directory: Directory, completionHandler: @escaping (Bool) -> Void) {
        guard let ubiquityURL = ubiquityURL else {
            completionHandler(false)
            return
        }
        
        var localFiles = [URL]()
        let keys = [URLResourceKey.contentModificationDateKey]
        
        do {
            let localDirectory = directory.formUrl(parentUrl: localURL)
            localFiles = try FileManager.default.contentsOfDirectory(at: localDirectory,
                                                                     includingPropertiesForKeys: keys,
                                                                     options: .skipsHiddenFiles)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain {
                switch error.code {
                case NSFileReadNoSuchFileError: break // Invalid workspace, nothing to do
                default: break
                }
            }
        }
        
        guard !localFiles.isEmpty else {
            completionHandler(true)
            return
        }
        
        let coordinator = NSFileCoordinator(filePresenter: self)
        let ubiquityDirectory = directory.formUrl(parentUrl: ubiquityURL)
        let readErr = NSErrorPointer(nilLiteral: ())
        let writeErr = NSErrorPointer(nilLiteral: ())
        var readFailed = true
        var writeFailed = true
        var someWriteFailed = false
        var nextFile: URL! = nil
        
        // The closure that moves a single file to the ubiquity container
        let moveFile: (URL) -> Void = { url in
            do {
                try FileManager.default.setUbiquitous(true, itemAt: nextFile, destinationURL: url)
                writeFailed = false
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    default: break
                    }
                }
            }
        }
        
        // The closure that replaces a single file in the ubiquity container
        let replaceFile: (URL) -> Void = { url in
            do {
                if let data = FileManager.default.contents(atPath: nextFile.path) {
                    try data.write(to: url, options: [.atomic])
                    try FileManager.default.removeItem(at: nextFile)
                    writeFailed = false
                }
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    default: break
                    }
                }
            }
        }
        
        // The closure that checks whether any files need to move/replace another
        let moveFiles: (() -> Void) -> Void = { endBlock in
            coordinator.coordinate(readingItemAt: ubiquityDirectory, options: [], error: readErr) { url in
                do {
                    let urls = try FileManager.default.contentsOfDirectory(at: url,
                                                                           includingPropertiesForKeys: keys,
                                                                           options: .skipsHiddenFiles)
                    readFailed = false
                    for localFile in localFiles {
                        let url = urls.first { $0.lastPathComponent == localFile.lastPathComponent }
                        if let url = url {
                            let localDate = try localFile.resourceValues(forKeys: Set(keys))
                                .contentModificationDate
                            let ubiquityDate = try url.resourceValues(forKeys: Set(keys))
                                .contentModificationDate
                            if localDate != nil && ubiquityDate != nil && ubiquityDate! < localDate! {
                                nextFile = localFile
                                writeFailed = true
                                coordinator.coordinate(writingItemAt: url,
                                                       options: [],
                                                       error: writeErr,
                                                       byAccessor: replaceFile)
                                if writeFailed { someWriteFailed = true }
                            }
                        } else {
                            let url = ubiquityDirectory.appendingPathComponent(localFile.lastPathComponent)
                            nextFile = localFile
                            writeFailed = true
                            coordinator.coordinate(writingItemAt: url,
                                                   options: [],
                                                   error: writeErr,
                                                   byAccessor: moveFile)
                            if writeFailed { someWriteFailed = true }
                        }
                    }
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        case NSFileReadNoSuchFileError: break // Invalid workspace, nothing to do
                        default: break
                        }
                    }
                }
            }
        }
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation {
            coordinator.prepare(forReadingItemsAt: [ubiquityDirectory],
                                options: [],
                                writingItemsAt: [ubiquityDirectory],
                                options: [],
                                error: readErr,
                                byAccessor: moveFiles)
            completionHandler(!(readFailed || someWriteFailed))
        }
    }
    
    /// Writes a `DataFile` to disk asynchronously.
    ///
    /// - Parameters:
    ///   - dataFile: The `DataFile` instance whose data should be stored.
    ///   - directory: The `Directory` defining the file's destination.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    private func write(dataFile: DataFile, directory: Directory, completionHandler: @escaping (Bool) -> Void) {
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let readErr = NSErrorPointer(nilLiteral: ())
        let writeErr = NSErrorPointer(nilLiteral: ())
        var readFailed = true
        var writeFailed = true
        var invalidWorkspace = false
        
        // The closure that writes over an existing file
        let writeOver: (URL) -> Void = { url in
            do {
                try dataFile.contents.write(to: url, options: [.atomic])
                writeFailed = false
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    default: break
                    }
                }
            }
        }
        
        // The closure that creates a new file
        let create: (URL) -> Void = { [unowned self] url in
            do {
                let isUbiquitous = try url.resourceValues(forKeys: [.isUbiquitousItemKey]).isUbiquitousItem
                if isUbiquitous == true {
                    let localDirectory = directory.formUrl(parentUrl: self.localURL)
                    let file = localDirectory.appendingPathComponent(dataFile.fileName)
                    try dataFile.contents.write(to: file, options: [.atomic])
                    try FileManager.default.setUbiquitous(true, itemAt: file, destinationURL: url)
                } else {
                    try dataFile.contents.write(to: url, options: [.atomic])
                }
                writeFailed = false
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    default: break
                    }
                }
            }
        }
        
        // The closure that checks whether to create a new file or write over an existing one
        let readWrite: (URL, URL) -> Void = { readUrl, writeUrl in
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: readUrl,
                                                                       includingPropertiesForKeys: [],
                                                                       options: .skipsHiddenFiles)
                readFailed = false
                coordinator.coordinate(writingItemAt: writeUrl,
                                       options: [],
                                       error: writeErr,
                                       byAccessor: urls.contains(writeUrl) ? writeOver : create)
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    case NSFileReadNoSuchFileError: invalidWorkspace = true
                    default: break
                    }
                }
            }
        }
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation { [unowned self] in
            let targetDirectory = self.ubiquityURL == nil ?
                directory.formUrl(parentUrl: self.localURL) :
                directory.formUrl(parentUrl: self.ubiquityURL!)
            
            coordinator.coordinate(readingItemAt: targetDirectory,
                                   options: [.withoutChanges],
                                   writingItemAt: targetDirectory.appendingPathComponent(dataFile.fileName),
                                   options: [.forReplacing],
                                   error: readErr,
                                   byAccessor: readWrite)
            
            if invalidWorkspace {
                var url: URL?
                if self.ubiquityURL == nil, self.createLocalWorkspace() {
                    url = directory.formUrl(parentUrl: self.localURL)
                } else if self.ubiquityURL != nil, self.createUbiquityWorkspace() {
                    url = directory.formUrl(parentUrl: self.ubiquityURL!)
                }
                if let url = url?.appendingPathComponent(dataFile.fileName) {
                    readFailed = false
                    coordinator.coordinate(writingItemAt: url,
                                           options: [],
                                           error: writeErr,
                                           byAccessor: create)
                }
            }
            
            completionHandler(!(readFailed || writeFailed))
        }
    }
    
    /// Reads a `DataFile` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - fileName: The name of a `DataFile` whose data should be retrieved.
    ///   - directory: The `Directory` defining the file's location.
    ///   - completionHandler: A closure to be called on completion, which will hold the contents of the
    ///     file on success or `nil` if the data could not be read.
    ///
    private func read(fileName: String, directory: Directory, completionHandler: @escaping (Data?) -> Void) {
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let file = ubiquityURL != nil ?
            directory.formUrl(parentUrl: ubiquityURL!).appendingPathComponent(fileName) :
            directory.formUrl(parentUrl: localURL).appendingPathComponent(fileName)
        
        let readErr = NSErrorPointer(nilLiteral: ())
        var data: Data?
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation {
            coordinator.coordinate(readingItemAt: file, options: [], error: readErr) { url in
                data = FileManager.default.contents(atPath: url.path)
            }
            completionHandler(data)
        }
    }
    
    /// Reads all `DataFile`s from disk asynchronously.
    ///
    /// - Parameters:
    ///   - directory: The `Directory` defining the location of the files.
    ///   - completionHandler: A closure to be called on completion, which will hold a list of
    ///     all contents of the directory.
    ///
    private func readAll(directory: Directory, completionHandler: @escaping ([Data]) -> Void) {
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let targetDirectory = ubiquityURL != nil ?
            directory.formUrl(parentUrl: ubiquityURL!) :
            directory.formUrl(parentUrl: localURL)
        
        let readErr = NSErrorPointer(nilLiteral: ())
        var allData = [Data]()
        
        // The closure that performs the read of all files
        let readAllFiles: (() -> Void) -> Void = { endBlock in
            coordinator.coordinate(readingItemAt: targetDirectory, options: [], error: readErr) { url in
                do {
                    let urls = try FileManager.default.contentsOfDirectory(at: url,
                                                                           includingPropertiesForKeys: [],
                                                                           options: .skipsHiddenFiles)
                    let options: NSFileCoordinator.ReadingOptions = [.withoutChanges]
                    urls.forEach {
                        coordinator.coordinate(readingItemAt: $0, options: options, error: readErr) { url in
                            if let data = FileManager.default.contents(atPath: url.path) {
                                allData.append(data)
                            }
                        }
                    }
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        case NSFileReadNoSuchFileError: break // Invalid workspace, write will handle it
                        default: break
                        }
                    }
                }
            }
            endBlock()
        }
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation {
            coordinator.prepare(forReadingItemsAt: [targetDirectory],
                                options: [],
                                writingItemsAt: [],
                                options: [],
                                error: readErr,
                                byAccessor: readAllFiles)
            completionHandler(allData)
        }
    }
    
    /// Deletes a `DataFile` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - dataFile: The `DataFile` instance whose data should be deleted.
    ///   - directory: The `Directory` defining the file's location.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    private func delete(dataFile: DataFile, directory: Directory,
                        completionHandler: @escaping (Bool) -> Void) {
        
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let fileName = dataFile.fileName
        let file = ubiquityURL != nil ?
            directory.formUrl(parentUrl: ubiquityURL!).appendingPathComponent(fileName) :
            directory.formUrl(parentUrl: localURL).appendingPathComponent(fileName)
        
        let writeErr = NSErrorPointer(nilLiteral: ())
        var writeFailed = true
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation {
            coordinator.coordinate(writingItemAt: file, options: [.forDeleting], error: writeErr) { url in
                do {
                    try FileManager.default.removeItem(at: url)
                    writeFailed = false
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        default: break
                        }
                    }
                }
            }
            completionHandler(!writeFailed)
        }
    }
    
    /// Downloads `DataFile`s asynchronously.
    ///
    /// - Parameters:
    ///   - directory: The `Directory` defining the location of the files.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    private func download(directory: Directory, completionHandler: @escaping (Bool) -> Void) {
        guard let ubiquityURL = ubiquityURL else {
            completionHandler(false)
            return
        }
        
        let coordinator = NSFileCoordinator(filePresenter: self)
        let targetDirectory = directory.formUrl(parentUrl: ubiquityURL)
        let keys: [URLResourceKey] = [.ubiquitousItemDownloadingStatusKey, .ubiquitousItemDownloadRequestedKey]
        let readErr = NSErrorPointer(nilLiteral: ())
        let writeErr = NSErrorPointer(nilLiteral: ())
        var readFailed = true
        var downloaded = true
        
        // The closure that performs the required download process for a file
        let processFile: (URL) -> Void = { url in
            do {
                guard let status = try url.resourceValues(forKeys: Set(keys)).ubiquitousItemDownloadingStatus
                    else { return }
                
                switch status {
                case .notDownloaded:
                    downloaded = false
                    if try url.resourceValues(forKeys: Set(keys)).ubiquitousItemDownloadRequested != true {
                        try FileManager.default.startDownloadingUbiquitousItem(at: url)
                    }
                default:
                    break
                }
            } catch let error as NSError {
                if error.domain == NSCocoaErrorDomain {
                    switch error.code {
                    default: break
                    }
                }
            }
        }
        
        // The closure that performs the read of the directory contents
        let readDirectoryContents: (() -> Void) -> Void = { endBlock in
            coordinator.coordinate(readingItemAt: targetDirectory, options: [], error: readErr) { url in
                do {
                    let urls = try FileManager.default.contentsOfDirectory(at: url,
                                                                           includingPropertiesForKeys: keys,
                                                                           options: [])
                    readFailed = false
                    urls.forEach {
                        coordinator.coordinate(writingItemAt: $0,
                                               options: [],
                                               error: writeErr,
                                               byAccessor: processFile)
                    }
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        case NSFileReadNoSuchFileError: break // Invalid workspace, nothing to do
                        default: break
                        }
                    }
                }
            }
            endBlock()
        }
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation { [unowned self] in
            coordinator.prepare(forReadingItemsAt: [targetDirectory],
                                options: [],
                                writingItemsAt: [targetDirectory],
                                options: [],
                                error: nil,
                                byAccessor: readDirectoryContents)
            if readFailed {
                completionHandler(false)
            } else if downloaded {
                completionHandler(true)
            } else {
                // Schedule a call to this method sometime in the future to check if the download completed
                let time = DispatchTime(uptimeNanoseconds: mach_absolute_time() + 1_000_000_000)
                self.queue.asyncAfter(deadline: time) { [unowned self] in
                    self.download(directory: directory, completionHandler: completionHandler)
                }
            }
        }
    }
    
    /// Checks if a given `Directory` has any contents, asynchronously.
    ///
    /// - Parameters:
    ///   - directory: The `Directory` to check.
    ///   - completionHandler: A closure to be called on completion, with an optional flag stating
    ///     whether or not the directory is empty. If the flag holds `nil`, the operation failed.
    ///
    private func isDirectoryEmpty(_ directory: Directory, completionHandler: @escaping (Bool?) -> Void) {
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let targetDirectory = ubiquityURL != nil ?
            directory.formUrl(parentUrl: ubiquityURL!) :
            directory.formUrl(parentUrl: localURL)
        
        let readErr = NSErrorPointer(nilLiteral: ())
        var readFailed = true
        var isEmpty = true
        
        // Enqueue the operation
        presentedItemOperationQueue.addOperation {
            coordinator.coordinate(readingItemAt: targetDirectory, options: [.withoutChanges], error: readErr)
            { url in
                do {
                    isEmpty = try FileManager.default.contentsOfDirectory(at: url,
                                                                          includingPropertiesForKeys: [],
                                                                          options: []).isEmpty
                    readFailed = false
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        case NSFileReadNoSuchFileError: break // Invalid workspace, nothing to do
                        default: break
                        }
                    }
                }
            }
            completionHandler(readFailed ? nil : isEmpty)
        }
    }
    
    /// Makes initial preparations for data file management asynchronously.
    ///
    /// - Note: Attempting to use the `DataFileManager` before this method executes the completion handler
    ///   will likely cause a crash.
    ///
    /// - Parameter completionHandler: A closure to be called on completion.
    ///
    func prepare(completionHandler: @escaping () -> Void) {
        presentedItemOperationQueue.addOperation { [unowned self] in
            var flag: Bool
            
            flag = self.createLocalWorkspace(); assert(flag)
            
            guard self.ubiquityToken != nil else {
                completionHandler()
                return
            }
            
            flag = self.createUbiquityWorkspace(); assert(flag)
            
            let sem = (DispatchSemaphore(value: 0), DispatchSemaphore(value: 0))
            self.move(directory: .configurationFiles) {
                assert($0)
                sem.0.signal()
            }
            self.move(directory: .saveFiles) {
                assert($0)
                sem.1.signal()
            }
            sem.0.wait()
            sem.1.wait()
            
            completionHandler()
        }
    }
    
    /// Writes `RawData` to disk asynchronously.
    ///
    /// - Parameters:
    ///   - rawData: The `RawData` instance whose data should be stored.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    func write(rawData: RawData, completionHandler: @escaping (Bool) -> Void) {
        write(dataFile: rawData, directory: .saveFiles, completionHandler: completionHandler)
    }
    
    /// Writes `ConfigurationData` to disk asynchronously.
    ///
    /// - Parameters:
    ///   - configurationData: The `ConfigurationData` instance whose data should be stored.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    func write(configurationData: ConfigurationData, completionHandler: @escaping (Bool) -> Void) {
        write(dataFile: configurationData, directory: .configurationFiles,
              completionHandler: completionHandler)
    }
    
    /// Reads `RawData` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - fileName: The name of the `RawData` file whose data should be retrieved.
    ///   - completionHandler: A closure to be called on completion, which will hold the contents of the
    ///     file on success or `nil` if the data could not be read.
    ///
    func read(rawDataNamed fileName: String, completionHandler: @escaping (Data?) -> Void) {
        read(fileName: fileName, directory: .saveFiles, completionHandler: completionHandler)
    }
    
    /// Reads `ConfigurationData` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - fileName: The name of the `ConfigurationData` file whose data should be retrieved.
    ///   - completionHandler: A closure to be called on completion, which will hold the contents of the
    ///     file on success or `nil` if the data could not be read.
    ///
    func read(configurationDataNamed fileName: String, completionHandler: @escaping (Data?) -> Void) {
        read(fileName: fileName, directory: .configurationFiles, completionHandler: completionHandler)
    }
    
    /// Reads all `RawData` from disk asynchronously.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, which will hold a list
    ///   with the contents of each file found.
    ///
    func readAllRawData(completionHandler: @escaping ([Data]) -> Void) {
        readAll(directory: .saveFiles, completionHandler: completionHandler)
    }
    
    /// Reads all `ConfigurationData` from disk asynchronously.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, which will hold a list
    ///   with the contents of each file found.
    ///
    func readAllConfigurationData(completionHandler: @escaping ([Data]) -> Void) {
        readAll(directory: .configurationFiles, completionHandler: completionHandler)
    }
    
    /// Deletes `RawData` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - rawData: The `RawData` instance whose data should be deleted.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    func delete(rawData: RawData, completionHandler: @escaping (Bool) -> Void) {
        delete(dataFile: rawData, directory: .saveFiles, completionHandler: completionHandler)
    }
    
    /// Deletes `ConfigurationData` from disk asynchronously.
    ///
    /// - Parameters:
    ///   - configurationData: The `ConfigurationData` instance whose data should be deleted.
    ///   - completionHandler: A closure to be called on completion, with a flag stating whether the
    ///     operation succeeded.
    ///
    func delete(configurationData: ConfigurationData, completionHandler: @escaping (Bool) -> Void) {
        delete(dataFile: configurationData, directory: .configurationFiles,
               completionHandler: completionHandler)
    }
    
    /// Downloads `RawData` asynchronously.
    ///
    /// - Note: This method may take a non-trivial amount of time to call the completion handler.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, with a flag stating whether
    ///   the operation succeeded.
    ///
    func downloadRawData(completionHandler: @escaping (Bool) -> Void) {
        download(directory: .saveFiles, completionHandler: completionHandler)
    }
    
    /// Downloads `ConfigurationData` asynchronously.
    ///
    /// - Note: This method may take a non-trivial amount of time to call the completion handler.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, with a flag stating whether
    ///   the operation succeeded.
    ///
    func downloadConfigurationData(completionHandler: @escaping (Bool) -> Void) {
        download(directory: .configurationFiles, completionHandler: completionHandler)
    }
    
    /// Checks if the directory holding `RawData` files has any contents, asynchronously.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, with an optional flag
    ///   stating whether or not the directory is empty. If the flag holds `nil`, the operation failed.
    ///
    func isSavesDirectoryEmpty(completionHandler: @escaping (Bool?) -> Void) {
        isDirectoryEmpty(.saveFiles, completionHandler: completionHandler)
    }
    
    /// Checks if the directory holding `ConfigurationData` files has any contents, asynchronously.
    ///
    /// - Parameter completionHandler: A closure to be called on completion, with an optional flag
    ///   stating whether or not the directory is empty. If the flag holds `nil`, the operation failed.
    ///
    func isConfigurationsDirectoryEmpty(completionHandler: @escaping (Bool?) -> Void) {
        isDirectoryEmpty(.configurationFiles, completionHandler: completionHandler)
    }
    
    /// Terminates the data file management.
    ///
    /// - Note: Attempting to use the `DataFileManager` after this method is called may cause
    ///   data inconsistencies.
    ///
    func terminate() {
        if ubiquityURL != nil {
            move(directory: .configurationFiles) { assert($0) }
            move(directory: .saveFiles) { assert($0) }
        }
        presentedItemOperationQueue.waitUntilAllOperationsAreFinished()
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    func presentedItemDidMove(to newURL: URL) {
        let flag = createUbiquityWorkspace(); assert(flag)
    }

    func presentedSubitem(at url: URL, didGain version: NSFileVersion) {
        let coordinator = NSFileCoordinator(filePresenter: self)
        
        let writeErr = NSErrorPointer(nilLiteral: ())
        var writeFailed = true
        
        presentedItemOperationQueue.addOperation {
            coordinator.coordinate(writingItemAt: url, options: [], error: writeErr) { url in
                do {
                    version.isResolved = true
                    try NSFileVersion.removeOtherVersionsOfItem(at: url)
                    writeFailed = false
                } catch let error as NSError {
                    if error.domain == NSCocoaErrorDomain {
                        switch error.code {
                        default: break
                        }
                    }
                }
            }
            assert(!writeFailed)
        }
    }
}
