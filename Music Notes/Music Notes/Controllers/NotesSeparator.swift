//
//  NotesSeparator.swift
//  Music Notes
//
//  Created by Aleksandra Front on 08/01/2022.
//

import Foundation
import UIKit
import SwiftUI

class NotesSeparator {
    let entireImage: UIImage
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    
    //entire image place on the staff
    let entireImageXOffset: CGFloat
    let entireImageYOffset: CGFloat
    
    //entire image pixels
    var pixelsData: [[PixelRGBA]]
    //coordinates
    var currentNotePositionXmin: Int
    var currentNotePositionXMax = 0
    var currentNotePositionYmin: Int
    var currentNotePositionYmax = 0
    
    //recursively algorithm
    var isPixelVisited: [[Bool]]
    var currentNoteColorPixels: [PixelWithPosition] = []
    
    //iteratively algorithm
    var pixelsLabels: [[Int]]
    var labelsDictionary: Set<SetElement>
    var finalLabelsDictionary: Set<Int>
    var finalLabelsDictionaryArray: [Int]
    var labelsWithPixels: [Int : OneNoteData]
    
    //result arrays with notes images
    var separatedNotesWithPosition: [UIImageWithPosition] = []
    
    init(entireImage: UIImage, entireImageXOffset: CGFloat, entireImageYOffset: CGFloat) {
        self.entireImage = entireImage
        self.imageWidth = entireImage.size.width
        self.imageHeight = entireImage.size.height
        self.pixelsData = entireImage.pixel2DData()!
        self.pixelsLabels = Array(repeating: Array(repeating: 0, count: Int(imageWidth)), count: Int(imageHeight))
        self.isPixelVisited = Array(repeating: Array(repeating: false, count: Int(imageWidth)), count: Int(imageHeight))
        self.currentNotePositionXmin = Int(imageWidth)
        self.currentNotePositionYmin = Int(imageHeight)
        self.entireImageXOffset = entireImageXOffset
        self.entireImageYOffset = entireImageYOffset
        self.labelsDictionary = Set<SetElement>()
        self.finalLabelsDictionary = Set<Int>()
        self.labelsWithPixels = [Int : OneNoteData]()
        self.finalLabelsDictionaryArray = []
    }
    
    func separateNotesIteratively() {
        var globalLabelNumber = 1
        for j in 0..<Int(imageWidth) {
            for i in 0..<Int(imageHeight) {
                var indexPlaceInY: IndexPlace = .SafeArea
                var indexPlaceInX: IndexPlace = .SafeArea
                var finalIndexPlace: IndexPlace = .SafeArea
                
                if (i == 0) {
                    indexPlaceInY = .UpperEdge
                }
                if (i == Int(imageHeight) - 1) {
                    indexPlaceInY = .LowerEdge
                }
                if (j == 0) {
                    indexPlaceInX = .LeftEdge
                }
                if (j == Int(imageWidth) - 1) {
                    indexPlaceInX = .RightEdge
                }
                
                if (indexPlaceInX != .SafeArea && indexPlaceInY != .SafeArea) {
                    if (indexPlaceInX == .LeftEdge && indexPlaceInY == .UpperEdge) {
                        finalIndexPlace = .LeftUpCorner
                    }
                    if (indexPlaceInX == .RightEdge && indexPlaceInY == .UpperEdge) {
                        finalIndexPlace = .RightUpCorner
                    }
                    if (indexPlaceInX == .LeftEdge && indexPlaceInY == .LowerEdge) {
                        finalIndexPlace = .LeftDownCorner
                    }
                    if (indexPlaceInX == .RightEdge && indexPlaceInY == .LowerEdge) {
                        finalIndexPlace = .RightDownCorner
                    }
                } else if (indexPlaceInX != .SafeArea) {
                    finalIndexPlace = indexPlaceInX
                } else {
                    finalIndexPlace = indexPlaceInY
                }
                
                switch finalIndexPlace {
                case .SafeArea, .RightEdge:
                    //indeksy nie są na brzegach
                    if (!pixelsData[i][j].isWhite()) {
                        //jest kolor
                        if (pixelsLabels[i-1][j] != 0 ||
                            pixelsLabels[i-1][j-1] != 0 ||
                            pixelsLabels[i][j-1] != 0 ||
                            pixelsLabels[i+1][j-1] != 0) {
                            //jakiś sąsiad jest olabelowany
                            //[up, upleft, left, downleft]
                            let labelsFound = [pixelsLabels[i-1][j], pixelsLabels[i-1][j-1], pixelsLabels[i][j-1], pixelsLabels[i+1][j-1]]
                            self.labelPixel(labelsFound: labelsFound, i: i, j: j)
                        } else if (pixelsData[i][j].r != 255 &&
                                   pixelsLabels[i-1][j] == 0 &&
                                   pixelsLabels[i-1][j-1] == 0 &&
                                   pixelsLabels[i][j-1] == 0 &&
                                   pixelsLabels[i+1][j-1] == 0) {
                            //jest kolor i żaden sąsiad nie jest olabelowany
                            pixelsLabels[i][j] = globalLabelNumber
                            globalLabelNumber += 1
                        }
                    }
                case .UpperEdge, .RightUpCorner:
                    if (!pixelsData[i][j].isWhite()) {
                        if (pixelsLabels[i][j-1] != 0 || pixelsLabels[i+1][j-1] != 0) {
                            //jakiś sąsiad jest olabelowany
                            //[left, leftdown]
                            let labelsFound = [pixelsLabels[i][j-1], pixelsLabels[i+1][j-1]]
                            self.labelPixel(labelsFound: labelsFound, i: i, j: j)
                        } else if (pixelsLabels[i][j-1] == 0 && pixelsLabels[i+1][j-1] == 0) {
                            //jest kolor i żaden sąsiad nie jest olabelowany
                            pixelsLabels[i][j] = globalLabelNumber
                            globalLabelNumber += 1
                        }
                    }
                case .LeftDownCorner, .LeftEdge:
                    if (!pixelsData[i][j].isWhite()) {
                        if (pixelsLabels[i-1][j] != 0) {
                            //jakiś sąsiad jest olabelowany
                            //[up]
                            let labelsFound = [pixelsLabels[i-1][j]]
                            self.labelPixel(labelsFound: labelsFound, i: i, j: j)
                        } else {
                            //jest kolor i żaden sąsiad nie jest olabelowany
                            pixelsLabels[i][j] = globalLabelNumber
                            globalLabelNumber += 1
                        }
                    }
                case .LowerEdge, .RightDownCorner:
                    if (!pixelsData[i][j].isWhite()) {
                        if (pixelsLabels[i-1][j] != 0 ||
                            pixelsLabels[i-1][j-1] != 0 ||
                            pixelsLabels[i][j-1] != 0) {
                            //jakiś sąsiad jest olabelowany
                            //[up, upleft, left]
                            let labelsFound = [pixelsLabels[i-1][j], pixelsLabels[i-1][j-1], pixelsLabels[i][j-1]]
                            self.labelPixel(labelsFound: labelsFound, i: i, j: j)
                        } else if (pixelsLabels[i-1][j] == 0 && pixelsLabels[i-1][j-1] == 0 && pixelsLabels[i][j-1] == 0) {
                            //jest kolor i żaden sąsiad nie jest olabelowany
                            pixelsLabels[i][j] = globalLabelNumber
                            globalLabelNumber += 1
                        }
                    }
                case .LeftUpCorner:
                    if (!pixelsData[i][j].isWhite()) {
                        //jest kolor i żaden sąsiad nie jest sprawdzany
                        pixelsLabels[i][j] = globalLabelNumber
                        globalLabelNumber += 1
                    }
                }
            }
        }
        
        self.processPixelLabels()
        self.crateLablesWithPixels()
        self.extractNotes()
    }
    
    func labelPixel(labelsFound: [Int], i: Int, j: Int) {
        var label = 0
        var uniqueLabels = Set<Int>()
        
        for k in 0..<labelsFound.count {
            if (labelsFound[k] != 0) {
                uniqueLabels.insert(labelsFound[k])
            }
        }
        if (uniqueLabels.count != 1) {
            //konflikt
            let uniqueLabelsArray = Array(uniqueLabels)
            let setElement = insertIntoLabelsDictionary(label1: uniqueLabelsArray[0],
                                                        label2: uniqueLabelsArray[1])
            label = min(setElement.labelNumber1,
                        setElement.labelNumber2)
        } else {
            label = uniqueLabels.first!
        }
        
        pixelsLabels[i][j] = label
    }
    
    func insertIntoLabelsDictionary(label1: Int, label2: Int) -> SetElement {
        let minLabel1 = getMinDefinitionOfLabel(labelNumber: label1)
        let minLabel2 = getMinDefinitionOfLabel(labelNumber: label2)
        let setElement = SetElement(labelNumber1: minLabel1,
                                    labelNumber2: minLabel2)
        labelsDictionary.insert(setElement)
        return setElement
    }
    
    func extractNotes() {
        finalLabelsDictionaryArray.forEach { label in
            var noteData = labelsWithPixels[label]
            let noteWidth = noteData!.maxX - noteData!.minX + 1
            let noteHeight = noteData!.maxY - noteData!.minY + 1
            var finalPixelsArray: [[PixelRGBA]] = Array(repeating: Array(repeating: PixelRGBA(),
                                                                         count: noteWidth),
                                                        count: noteHeight)
            noteData!.colorPixels.forEach { pixelWithPosition in
                finalPixelsArray[pixelWithPosition.rowIndex - noteData!.minY][pixelWithPosition.columnIndex - noteData!.minX] = pixelWithPosition.pixel
            }
            
            let finalPixelsArray1D = NotesSeparator.array2DTo1D(array2D: finalPixelsArray,
                                                                width: noteWidth,
                                                                height: noteHeight)
            let image = UIImage(pixels: finalPixelsArray1D,
                                width: noteWidth,
                                height: noteHeight)
            let imageWithPosition = UIImageWithPosition(image: image!,
                                                        offsetX: noteData!.minX/3 + Int(entireImageXOffset),
                                                        offsetY: noteData!.minY/3 + Int(entireImageYOffset))
            self.separatedNotesWithPosition.append(imageWithPosition)
        }
    }
    
    func crateLablesWithPixels() {
        for j in 0..<Int(imageWidth) {
            for i in 0..<Int(imageHeight) {
                var label = pixelsLabels[i][j]
                if (label != 0) {
                    let pixel = PixelWithPosition(pixel: pixelsData[i][j], rowIndex: i, columnIndex: j)
                    if (labelsWithPixels[label] == nil) {
                        let noteData = OneNoteData(colorPixels: [pixel],
                                                    minX: j,
                                                    minY: i,
                                                    maxX: 0,
                                                    maxY: 0)
                        labelsWithPixels[label] = noteData
                    } else {
                        labelsWithPixels[label]!.colorPixels.append(pixel)
                        if (i > labelsWithPixels[label]!.maxY) {
                            labelsWithPixels[label]!.maxY = i
                        }
                        if (i < labelsWithPixels[label]!.minY) {
                            labelsWithPixels[label]!.minY = i
                        }
                        if (j > labelsWithPixels[label]!.maxX) {
                            labelsWithPixels[label]!.maxX = j
                        }
                        if (j < labelsWithPixels[label]!.minX) {
                            labelsWithPixels[label]!.minX = j
                        }
                    }
                }
            }
        }
    }
    
    func processPixelLabels() {
        for j in 0..<Int(imageWidth) {
            for i in 0..<Int(imageHeight) {
                if (pixelsLabels[i][j] != 0) {
                    pixelsLabels[i][j] = getMinDefinitionOfLabel(labelNumber: pixelsLabels[i][j])
                    finalLabelsDictionary.insert(pixelsLabels[i][j])
                }
            }
        }
        finalLabelsDictionaryArray = finalLabelsDictionary.sorted()
    }
    
    func getMinDefinitionOfLabel(labelNumber: Int) -> Int {
        var currentMinLabel = labelNumber
        var continueLoop = true
    while_loop: while (continueLoop) {
     for def in labelsDictionary {
                if ((def.labelNumber1 == currentMinLabel || def.labelNumber2 == currentMinLabel) && (def.labelNumber1 < currentMinLabel || def.labelNumber2 < currentMinLabel)) {
                    currentMinLabel =  min(def.labelNumber1, def.labelNumber2)
                    continue while_loop
                }
            }
            continueLoop = false
        }
        return currentMinLabel
    }
    
    func separateNotesRecursively() {
        for j in 0..<Int(imageWidth) {
            for i in 0..<Int(imageHeight) {
                if (pixelsData[i][j].r != 255 && !isPixelVisited[i][j]) {
                    self.searchNote(i: i, j: j, direction: .FromLeft)
                    let oneNoteWidth = currentNotePositionXMax - currentNotePositionXmin + 1
                    let oneNoteHeight = currentNotePositionYmax - currentNotePositionYmin + 1
                    var oneNotePixelsData = Array(repeating: Array(repeating: PixelRGBA(), count: oneNoteWidth), count: oneNoteHeight)
                    currentNoteColorPixels.forEach { pixelWithPosition in
                        oneNotePixelsData[pixelWithPosition.rowIndex - currentNotePositionYmin][pixelWithPosition.columnIndex - currentNotePositionXmin] = pixelWithPosition.pixel
                    }
                    let oneNoteImage = UIImage(pixels: NotesSeparator.array2DTo1D(array2D: oneNotePixelsData, width: oneNoteWidth, height: oneNoteHeight),
                                               width: oneNoteWidth,
                                               height: oneNoteHeight)
                    separatedNotesWithPosition.append(UIImageWithPosition(image: oneNoteImage!,
                                                                          offsetX: currentNotePositionXmin + Int(entireImageXOffset),
                                                                          offsetY: currentNotePositionYmin/3 + Int(entireImageYOffset)))
                    
                    currentNotePositionXmin = Int(imageWidth)
                    currentNotePositionYmin = Int(imageHeight)
                    currentNotePositionXMax = 0
                    currentNotePositionYmax = 0
                    currentNoteColorPixels = []
                }
            }
        }
    }
    
    func searchNote(i: Int, j: Int, direction: Direction) {
        if (i >= 0 && i < Int(imageHeight) && j >= 0 && j < Int(imageWidth)) {
            if (pixelsData[i][j].r != 255 && !isPixelVisited[i][j]) {
                isPixelVisited[i][j] = true
                currentNoteColorPixels.append(PixelWithPosition(pixel: pixelsData[i][j], rowIndex: i, columnIndex: j))
                if (i > currentNotePositionYmax) {
                    currentNotePositionYmax = i
                }
                if (i < currentNotePositionYmin) {
                    currentNotePositionYmin = i
                }
                if (j > currentNotePositionXMax) {
                    currentNotePositionXMax = j
                }
                if (j < currentNotePositionXmin) {
                    currentNotePositionXmin = j
                }
                switch direction {
                case .FromRight:
                    searchNote(i: i, j: j-1, direction: .FromRight)
                    searchNote(i: i+1, j: j, direction: .FromUp)
                    searchNote(i: i-1, j: j, direction: .FromDown)
                case .FromLeft:
                    searchNote(i: i, j: j+1, direction: .FromLeft)
                    searchNote(i: i+1, j: j, direction: .FromUp)
                    searchNote(i: i-1, j: j, direction: .FromDown)
                case .FromDown:
                    searchNote(i: i, j: j+1, direction: .FromLeft)
                    searchNote(i: i, j: j-1, direction: .FromRight)
                    searchNote(i: i-1, j: j, direction: .FromDown)
                case .FromUp:
                    searchNote(i: i, j: j+1, direction: .FromLeft)
                    searchNote(i: i, j: j-1, direction: .FromRight)
                    searchNote(i: i+1, j: j, direction: .FromUp)
                }
            } else {
                return
            }
        } else {
            return
        }
    }
    
    static func array2DTo1D(array2D: [[PixelRGBA]], width: Int, height: Int) -> [PixelRGBA] {
        var array1D = [PixelRGBA](repeating: PixelRGBA(), count: width * height)
        for i in 0..<height {
            for j in 0..<width {
                array1D[i*width + j] = array2D[i][j]
            }
        }
        return array1D
    }
}

enum IndexPlace {
    case LeftEdge
    case RightEdge
    case LowerEdge
    case UpperEdge
    case LeftUpCorner
    case RightUpCorner
    case RightDownCorner
    case LeftDownCorner
    case SafeArea
}

enum Direction: String {
    case FromRight = "FromRight"
    case FromLeft = "FromLeft"
    case FromUp = "FromUp"
    case FromDown = "FromDown"
}

struct SetElement: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(labelNumber1)
        hasher.combine(labelNumber2)
    }
    var labelNumber1: Int
    var labelNumber2: Int
}

class PixelWithPosition {
    var pixel: PixelRGBA
    var rowIndex: Int
    var columnIndex: Int
    
    init() {
        self.pixel = PixelRGBA()
        self.rowIndex = 0
        self.columnIndex = 0
    }
    
    init(pixel: PixelRGBA, rowIndex: Int, columnIndex: Int) {
        self.pixel = pixel
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
    }
}

struct PixelRGBA {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
    
    init(alpha: UInt8, red: UInt8, green: UInt8, blue: UInt8) {
        self.r = red
        self.g = green
        self.b = blue
        self.a = alpha
    }
    
    init() {
        self.r = 255
        self.g = 255
        self.b = 255
        self.a = 255
    }
    
    func isWhite() -> Bool {
        if (r == 255 && g == 255 && b == 255 && a == 255) {
            return true
        }
        return false
    }
}


struct UIImageWithPosition {
    var image: UIImage
    var offsetX: Int
    var offsetY: Int
}

struct OneNoteData {
    public var colorPixels: [PixelWithPosition]
    var minX: Int
    var minY: Int
    var maxX: Int
    var maxY: Int
    
    init(colorPixels: [PixelWithPosition], minX: Int, minY: Int, maxX: Int, maxY: Int) {
        self.colorPixels = colorPixels
        self.minY = minY
        self.minX = minX
        self.maxX = maxX
        self.maxY = maxY
    }
    
    init(minX: Int, minY: Int, maxX: Int, maxY: Int) {
        self.colorPixels = []
        self.minY = minY
        self.minX = minX
        self.maxX = maxX
        self.maxY = maxY
    }
}
