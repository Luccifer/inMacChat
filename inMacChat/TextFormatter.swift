//
//  TextFormatter.swift
//  inMacChat
//
//  Created by Gleb Karpushkin on 22/04/16.
//  Copyright © 2016 Gleb Karpushkin. All rights reserved.
//

import Foundation

struct TextFormatter {
    
    func replaceBBtoHTML(text: String) -> String {
        let replacements = ["[b]" : "<b>", "[/b]" : "</b>", "[u]" : "<u>", "[/u]" : "</u>", "[s]" : "<s>", "[/s]" : "</s>"]
        
        var textString = text
        
        for (originalWord, newWord) in replacements {
            textString = textString.stringByReplacingOccurrencesOfString(originalWord, withString: newWord, options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        
        return textString
    }
    
    func completeText(text: String) -> NSAttributedString {
        
        var html = "\(replaceBBtoHTML(text))\n"
        
        // Replace newline character by HTML line break
        while let range = html.rangeOfString("\n") {
            html.replaceRange(range, with: "<br />")
        }
        
        // Embed in a <span> for font attributes:
        html = "<span style=\"font-family: Helvetica; font-size:13pt;\">" + html + "</span>"
        
        let data = html.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!
        let attrStr = try? NSAttributedString(
            data: data,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        return attrStr!
    }
}