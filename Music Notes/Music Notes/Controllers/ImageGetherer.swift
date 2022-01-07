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
    
    func getImageToCalculateHeight(drawingOneNote: PKDrawing, staffSize: CGSize) -> UIImage {
        let image = drawingOneNote.image(
            from: CGRect(origin: CGPoint(x: drawingOneNote.bounds.minX, y: 0),
                         size: CGSize(width: drawingOneNote.bounds.size.width,
                                      height: staffSize.height)
                  ),
                scale: 1.0
        )
        return image
    }
}
