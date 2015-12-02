//
//  String+htmlencodedstring.swift
//  Sigfood
//
//  Created by Kett, Oliver on 27.02.15.
//  Copyright (c) 2015 Kett, Oliver. All rights reserved.
//

import UIKit

extension String {
    func htmlDecodedString() -> String {
        return NSString.kv_decodeHTMLCharacterEntities(self)()
    }
    
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)
        } catch _ {
            self.init()
        }
    }
}