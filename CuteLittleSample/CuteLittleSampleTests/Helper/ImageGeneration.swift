//
//  ImageGeneration.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/22/23.
//

import Foundation
import UI

#if os(iOS)
import UIKit

func generateCheckerboardImage(size: CGSize, squareSize: CGFloat, color1: UIColor = .black, color2: UIColor = .white) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

    for x in stride(from: CGFloat(0), to: size.width, by: squareSize) {
        for y in stride(from: CGFloat(0), to: size.height, by: squareSize) {
            let isEvenX = Int(x / squareSize) % 2 == 0
            let isEvenY = Int(y / squareSize) % 2 == 0

            let color = (isEvenX == isEvenY) ? color1 : color2
            color.setFill()
            UIRectFill(CGRect(x: x, y: y, width: squareSize, height: squareSize))
        }
    }

    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

#elseif os(macOS)
import AppKit

func generateCheckerboardImage(size: CGSize, squareSize: CGFloat, color1: NSColor = .black, color2: NSColor = .white) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()

    for x in stride(from: CGFloat(0), to: size.width, by: squareSize) {
        for y in stride(from: CGFloat(0), to: size.height, by: squareSize) {
            let isEvenX = Int(x / squareSize) % 2 == 0
            let isEvenY = Int(y / squareSize) % 2 == 0

            let color = (isEvenX == isEvenY) ? color1 : color2
            color.setFill()
            let rect = NSRect(x: x, y: y, width: squareSize, height: squareSize)
            NSBezierPath(rect: rect).fill()
        }
    }

    image.unlockFocus()
    return image
}

#endif


// USAGE

//let image = generateCheckerboardImage(size: CGSize(width: 200, height: 200), squareSize: 20)
