//
//  UITextStyle.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 2/22/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An enum defining styles of text, intended to be used by `UIText` instances.
///
enum UITextStyle {
    case title, subtitle, text, emphasis, option, button, highlight
    case loading, gameOver
    case icon, waitTime, shortcut, bar
    case value, goodValue, badValue, lockedValue, price, gold, points, lock, resource, modifier
    case damage, healing, crit, xp
    
    /// Applies the text style to the given label.
    ///
    /// - Parameter label: The label to be styled.
    ///
    func applyStyle(label: SKLabelNode) {
        switch self {
        case .title:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.black
            label.fontSize = TextStyleData.Size.large
        case .subtitle:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .text:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.medium
        case .emphasis:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.italic
            label.fontSize = TextStyleData.Size.medium
        case .icon:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.tiny
        case .waitTime:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.large
        case .option:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .button:
            label.fontColor = TextStyleData.Color.dark
            label.fontName = TextStyleData.Font.black
            label.fontSize = TextStyleData.Size.small
        case .highlight:
            label.fontColor = TextStyleData.Color.greenish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .value:
            fallthrough
        case .goodValue:
            label.fontColor = TextStyleData.Color.greenish
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.medium
        case .badValue:
            label.fontColor = TextStyleData.Color.reddish
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.medium
        case .lockedValue:
            label.fontColor = TextStyleData.Color.reddish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .price:
            label.fontColor = TextStyleData.Color.golden
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .gold:
            label.fontColor = TextStyleData.Color.golden
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.medium
        case .bar:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.small
        case .loading:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.large
        case .gameOver:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.black
            label.fontSize = TextStyleData.Size.huge
        case .points:
            label.fontColor = TextStyleData.Color.bluish
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.medium
        case .lock:
            label.fontColor = TextStyleData.Color.bluish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.tiny
        case .resource:
            label.fontColor = TextStyleData.Color.purplish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        case .modifier:
            label.fontColor = TextStyleData.Color.greenish
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.small
        case .shortcut:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.regular
            label.fontSize = TextStyleData.Size.tiny
        case .damage:
            label.fontColor = TextStyleData.Color.reddish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.small
        case .healing:
            label.fontColor = TextStyleData.Color.greenish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.small
        case .crit:
            label.fontColor = TextStyleData.Color.reddish
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.large
        case .xp:
            label.fontColor = TextStyleData.Color.light
            label.fontName = TextStyleData.Font.bold
            label.fontSize = TextStyleData.Size.medium
        }
    }
    
    /// Highlights substrings in a text.
    ///
    /// The parts of the text that are not affected by highlight will be styled as `.text`, while
    /// the highlighted substrings will be styled as `.highlight`.
    ///
    /// - Parameters:
    ///   - text: The text to highlight.
    ///   - mark: A character that marks the boundaries of a substring to be highlighted.
    /// - Returns: A `NSAttributedString` representing the transformed text.
    ///
    static func applyHighlight(text: String, mark: Character) -> NSAttributedString {
        var ranges = [NSRange]()
        var current: Int? = nil
        for (i, c) in zip(text.indices, text) {
            guard c == mark else { continue }
            
            if current != nil {
                ranges.append(NSRange(current!..<(i.utf16Offset(in: text))))
                current = nil
            } else {
                current = i.utf16Offset(in: text) + 1
            }
        }
        
        let textAttr: [NSAttributedString.Key : Any]  = [
            .font: NSFont(name: TextStyleData.Font.regular, size: TextStyleData.Size.medium)!,
            .foregroundColor: TextStyleData.Color.light
        ]
        let highlightAttr: [NSAttributedString.Key : Any]  = [
            .font: NSFont(name: TextStyleData.Font.bold, size: TextStyleData.Size.medium)!,
            .foregroundColor: TextStyleData.Color.greenish
        ]
        
        let str = NSMutableAttributedString(string: text)
        let range = NSRange(0..<str.mutableString.length)
        str.beginEditing()
        str.addAttributes(textAttr, range: range)
        ranges.forEach { str.addAttributes(highlightAttr, range: $0) }
        str.endEditing()
        str.mutableString.replaceOccurrences(of: String(mark), with: "", options: [], range: range)
        
        return str
    }
}

/// A struct that defines the styles used by the `UITextStyle` class.
///
fileprivate struct TextStyleData {
    
    /// The colors.
    ///
    struct Color {
        static let light = NSColor(red: 0.865, green: 0.865, blue: 0.6, alpha: 1.0)
        static let dark = NSColor(red: 0.135, green: 0.135, blue: 0.175, alpha: 1.0)
        static let golden = NSColor(red: 0.965, green: 0.965, blue: 0.15, alpha: 1.0)
        static let reddish = NSColor(red: 0.695, green: 0.295, blue: 0.335, alpha: 1.0)
        static let greenish = NSColor(red: 0.295, green: 0.695, blue: 0.335, alpha: 1.0)
        static let bluish = NSColor(red: 0.395, green: 0.495, blue: 0.915, alpha: 1.0)
        static let purplish = NSColor(red: 0.465, green: 0.245, blue: 0.705, alpha: 1.0)
        static let bright = NSColor(white: 0.92, alpha: 1.0)
    }
    
    /// The fonts.
    ///
    struct Font {
        static let regular = "Optima"
        static let italic = "Optima Italic"
        static let bold = "Optima Bold"
        static let black = "Optima ExtraBlack"
    }
    
    /// The sizes.
    ///
    struct Size {
        static let tiny: CGFloat = 9.0
        static let small: CGFloat = 11.0
        static let medium: CGFloat = 13.0
        static let large: CGFloat = 16.0
        static let huge: CGFloat = 40.0
    }
}
