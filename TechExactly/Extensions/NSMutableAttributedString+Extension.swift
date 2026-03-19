//
//  NSMutableAttributedString+Extension.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 19/03/26.
//

import UIKit

extension NSMutableAttributedString {
    /// Toggles the given font trait (e.g. bold, italic) for the specified range.
    func toggleFontTrait(_ trait: UIFontDescriptor.SymbolicTraits,
                         in range: NSRange,
                         defaultFont: UIFont = UIFont.systemFont(ofSize: 18)) {
        self.enumerateAttribute(.font, in: range, options: []) { value, subrange, _ in
            let currentFont = (value as? UIFont) ?? defaultFont
            var traits = currentFont.fontDescriptor.symbolicTraits
            if traits.contains(trait) {
                traits.remove(trait)
            } else {
                traits.insert(trait)
            }
            if let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
                self.addAttribute(.font, value: newFont, range: subrange)
            }
        }
    }

    /// Toggles underline style for the specified range.
    func toggleUnderlineStyle(in range: NSRange) {
        self.enumerateAttribute(.underlineStyle, in: range, options: []) { value, subrange, _ in
            if let style = value as? Int, style == NSUnderlineStyle.single.rawValue {
                self.removeAttribute(.underlineStyle, range: subrange)
            } else {
                self.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: subrange)
            }
        }
    }
}
