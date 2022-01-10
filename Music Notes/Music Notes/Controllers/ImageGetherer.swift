//
//  ImageGetherer.swift
//  Music Notes
//
//  Created by Aleksandra Front on 08/12/2021.
//

import Foundation
import PencilKit
import SwiftUI

struct ImageGetherer {
    var handwritingArea: PKCanvasView
    var oneNote: UIImage = UIImage()
    var desirableDimension: CGFloat = 224
    var notes: [String] = []
    
    func cutStaff() {
        //cutting handwritingArea on the notes.
        //fill the notes array
    }
    
    mutating func processOneNoteImage(note: UIImage) -> UIImage {

        let drawingX = note.size.width
        let drawingY = note.size.height
        
        var imageX: CGFloat
        var imageY: CGFloat
        
        if (drawingX > drawingY){
            imageX = self.desirableDimension
            imageY = (drawingY/drawingX) * self.desirableDimension
        }
        else{
            imageY = self.desirableDimension
            imageX = (drawingX/drawingY) * self.desirableDimension
        }
        let newSize = CGSize(width: imageX, height: imageY)
        let rectangle = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        note.draw(in: rectangle)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageInDimension = self.drawNoteInProperDimensionImage(note: newImage!)
        
        self.oneNote = imageInDimension
        return self.oneNote
    }
    
    mutating func scaleAndRender(image: UIImage) -> UIImage {
        let drawingX = image.size.width
        let drawingY = image.size.height
        
        var imageX: CGFloat
        var imageY: CGFloat
        
        imageX = drawingX * 3
        imageY = drawingY * 3

        let newSize = CGSize(width: imageX, height: imageY)
        let rectangle = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rectangle)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageInDimension = self.drawNotesInProperDimensionImage(image: newImage!)
        return imageInDimension
    }
    
    func drawNoteInProperDimensionImage(note: UIImage) -> UIImage{
        var rectangle = CGRect(origin: .zero, size: CGSize(width: self.desirableDimension, height: self.desirableDimension))
        let xPosition = CGFloat.random(in: 0..<self.desirableDimension - note.size.width + 1)
        let yPosition = CGFloat.random(in: 0..<self.desirableDimension - note.size.height + 1)
        rectangle.origin = CGPoint(x: xPosition, y: yPosition)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.desirableDimension, height: self.desirableDimension), true, 1.0)
        UIColor.white.set()
        UIBezierPath(rect: CGRect(x:0, y: 0, width:desirableDimension, height:desirableDimension)).fill()
        note.draw(at: rectangle.origin)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func drawNotesInProperDimensionImage(image: UIImage) -> UIImage {
        var rectangle = CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height))
        let xPosition = 0
        let yPosition = 0
        rectangle.origin = CGPoint(x: xPosition, y: yPosition)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: image.size.width, height: image.size.height), true, 1.0)
        UIColor.white.set()
        UIBezierPath(rect: CGRect(x:0, y: 0, width: image.size.width, height: image.size.height)).fill()
        image.draw(at: rectangle.origin)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func getImageToCalculateHeight(uiImageWithPosition: UIImageWithPosition, staffSize: CGSize) -> UIImage {
        var scaledImage = UIImage(cgImage: uiImageWithPosition.image.cgImage!, scale: 3, orientation: uiImageWithPosition.image.imageOrientation)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: scaledImage.size.width, height: staffSize.height), false, 1.0)
        UIColor.white.set()
        
        var rectangle = CGRect(origin: .zero, size: CGSize(width: scaledImage.size.width, height: staffSize.height))
        let xPosition = 0
        let yPosition = uiImageWithPosition.offsetY
        rectangle.origin = CGPoint(x: xPosition, y: yPosition)
        
        
        UIBezierPath(rect: CGRect(x:0, y: 0, width: scaledImage.size.width, height: staffSize.height)).fill()
        scaledImage.draw(at: rectangle.origin)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage!
    }
}
