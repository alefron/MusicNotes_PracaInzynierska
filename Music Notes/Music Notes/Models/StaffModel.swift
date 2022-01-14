//
//  StaffModel.swift
//  Music Notes
//
//  Created by Aleksandra Front on 05/01/2022.
//

import Foundation
import SwiftUI

class StaffModel {
    public var step: CGFloat
    public var linesCount: Int
    private var size: CGSize
    public var fields: [StaffField] = []
    public var linesHeights: [CGFloat] = []
    public var whole: Note
    public var half: Note
    public var quarter: Note
    public var eight: Note
    public var sixteenth: Note
    public var restWhole: Note
    public var restHalf: Note
    public var restQuarter: Note
    public var restEight: Note
    public var restSixteenth: Note
    public var bemol: Note
    public var sharp: Note
    public var natural: Note
    public var dot: Note
    public var notesOnStaff: [Note] = []
    
    init() {
        step = 20
        linesCount = 9
        size = CGSize (width: 1080, height: 300)
        
        let firstLineHeight = size.height/2 - CGFloat((linesCount - 1)/2) * step
        let lastLineHeight = size.height/2 + CGFloat((linesCount - 1)/2) * step
        
        fields.append(StaffField(upperBound: 0, lowerBound: firstLineHeight, index: 1))
        
        //first set to first line height
        var currentLineHeight = firstLineHeight
        //set heights of all of the lines
        for _ in 1...linesCount {
            linesHeights.append(currentLineHeight)
            currentLineHeight += 20
        }
        
        var currentIndex = 2
        //set bounds of all of the staff fields
        for i in 0...linesCount - 1 {
            let upperBoundOnLine = linesHeights[i] - step/2
            let lowerBoundOnLine = linesHeights[i] + step/2
            
            let upperBoundOnField = linesHeights[i]
            let lowerBoundOnField = linesHeights[i] + step
            
            fields.append(StaffField(upperBound: upperBoundOnLine, lowerBound: lowerBoundOnLine, index: currentIndex))
            if (i != linesCount - 1) {
                fields.append(StaffField(upperBound: upperBoundOnField, lowerBound: lowerBoundOnField, index: currentIndex + 1))
            }
            currentIndex += 2
        }
        fields.append(StaffField(upperBound: lastLineHeight, lowerBound: size.height, index: currentIndex - 1))
        
        self.whole = Note()
        self.half = whole
        self.quarter = whole
        self.eight = whole
        self.sixteenth = whole
        self.restWhole = whole
        self.restHalf = whole
        self.restQuarter = whole
        self.restEight = whole
        self.restSixteenth = whole
        self.dot = whole
        self.natural = whole
        self.bemol = whole
        self.sharp = whole
    }
    
    init(step: CGFloat, linesAdded: Int, size: CGSize) {
        self.step = step
        self.linesCount = 5 + linesAdded + linesAdded
        self.size = size
        
        let firstLineHeight = size.height/2 - CGFloat((linesCount - 1)/2) * step
        let lastLineHeight = size.height/2 + CGFloat((linesCount - 1)/2) * step
        
        fields.append(StaffField(upperBound: 0, lowerBound: firstLineHeight, index: 1))
        
        //first set to first line height
        var currentLineHeight = firstLineHeight
        //set heights of all of the lines
        for _ in 1...linesCount {
            linesHeights.append(currentLineHeight)
            currentLineHeight += 20
        }
        
        var currentIndex = 2
        //set bounds of all of the staff fields
        for i in 0...linesCount - 1 {
            let upperBoundOnLine = linesHeights[i] - step/2
            let lowerBoundOnLine = linesHeights[i] + step/2
            
            let upperBoundOnField = linesHeights[i]
            let lowerBoundOnField = linesHeights[i] + step
            
            fields.append(StaffField(upperBound: upperBoundOnLine, lowerBound: lowerBoundOnLine, index: currentIndex))
            if (i != linesCount - 1) {
                fields.append(StaffField(upperBound: upperBoundOnField, lowerBound: lowerBoundOnField, index: currentIndex + 1))
            }
            currentIndex += 2
        }
        fields.append(StaffField(upperBound: lastLineHeight, lowerBound: size.height, index: currentIndex - 1))
        
        self.whole = Note(type: .whole, fields: fields, id: 0)
        self.half = Note(type: .half, fields: fields, id: 1)
        self.quarter = Note(type: .quarter, fields: fields, id: 2)
        self.eight = Note(type: .eight, fields: fields, id: 3)
        self.sixteenth = Note(type: .sixteenth, fields: fields, id: 4)
        self.restWhole = Note(type: .restWhole, fields: fields, id: 5)
        self.restHalf = Note(type: .restHalf, fields: fields, id: 6)
        self.restQuarter = Note(type: .restQuarter, fields: fields, id: 7)
        self.restEight = Note(type: .restEight, fields: fields, id: 8)
        self.restSixteenth = Note(type: .restSixteenth, fields: fields, id: 9)
        self.dot = Note(type: .dot, fields: fields, id: 10)
        self.natural = Note(type: .natural, fields: fields, id: 11)
        self.bemol = Note(type: .bemol, fields: fields, id: 12)
        self.sharp = Note(type: .sharp, fields: fields, id: 13)
    }
}

class StaffField {
    var upperBound: CGFloat
    var lowerBound: CGFloat
    var index: Int
    
    init(upperBound: CGFloat, lowerBound: CGFloat, index: Int) {
        self.upperBound = upperBound
        self.lowerBound = lowerBound
        self.index = index
    }
}
