//
//  Data+Extension.swift
//  TechExactly
//
//  Created by Pawan Kushwaha on 20/03/26.
//
import Foundation

extension Optional where Wrapped == Data {
    var attributedStr: NSAttributedString? {
        guard let data = self else { return nil }
        do {
            if let nsAttributed = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
                return nsAttributed
            }
        } catch {
            print("Error unarchiving attributed string: \(error)")
        }
        return nil
    }
}
