// Playground - noun: a place where people can play

import UIKit
import XCPlayground
import CoreData

struct emoji {
    static let no_entry_sign = "\u{1F6AB}"
    static let pig = "\u{1f437}"
    static let star = "\u{2b50}"
    static let apple = "\u{1f34e}"
    static let cow = "\u{1f42e}"
}

class EmojiImageGenerator {

    func imageWithEmoji(str: String, size: CGFloat) -> UIImage {
        let label = UILabel()
        label.font = UIFont(name: "Apple Color Emoji", size: size)
        label.text = str
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.frame = CGRect(x: 0, y: 0, width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, label.opaque, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func prohibitedImage(str: String, size: CGFloat) -> UIImage {
        let XYSize =  CGSize(width: 512, height: 512)
        let prohibited = imageWithEmoji(emoji.no_entry_sign, size: size) // no entry sign
        let image = imageWithEmoji(str, size: size)
        
        UIGraphicsBeginImageContextWithOptions(XYSize, false, 0.0)
        image.drawInRect(CGRect(origin: CGPoint.zero, size: XYSize))
        prohibited.drawInRect((CGRect(origin: CGPoint.zero, size: CGSize(width: 512.0, height: 512.0))))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

let imageGenerator = EmojiImageGenerator()
imageGenerator.prohibitedImage(emoji.pig, size: 512.0)
imageGenerator.imageWithEmoji(emoji.star, size: 512.0)
imageGenerator.imageWithEmoji(emoji.apple, size: 512.0)
imageGenerator.imageWithEmoji(emoji.cow, size: 512.0)