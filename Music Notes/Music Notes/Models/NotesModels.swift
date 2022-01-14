//
//  NotesModels.swift
//  Music Notes
//
//  Created by Aleksandra Front on 06/01/2022.
//

import Foundation
import UIKit
import SwiftUI

class Note: Hashable, ObservableObject {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    var imageWidth: CGFloat = 50
    var imageHeight: CGFloat = 100
    var scale: CGFloat = 0.8
    @Published var name: String?
    var image: UIImage?
    @Published var type: SignsTypes?
    var heightsInFields: [CGFloat] = [] //a place in Y axis where the image should be drawn
    var offset: CGFloat? //count from upper line of field
    @Published var fieldNumber: Int?
    var durationInSixteenth: Int?
    @Published var isSmall: Bool
    @Published var isSharpBefore: Bool = false
    @Published var isNaturalBefore: Bool = false
    @Published var isBemolBefore: Bool = false
    @Published var isDotAfter: Bool = false
    
    init() {
        self.id = 1
        self.type = .eight
        self.name = "eight"
        self.image = UIImage(named: "eight")
        self.offset = 4
        self.isSmall = false
       
        heightsInFields.append(100 + offset!)
        self.fieldNumber = 1
        durationInSixteenth = 2
    }
    
    init(note: Note, id: Int) {
        self.id = id
        self.imageWidth = note.imageWidth
        self.imageHeight = note.imageHeight
        self.scale = note.scale
        self.name = note.name
        self.image = note.image
        self.type = note.type
        self.heightsInFields = note.heightsInFields
        self.offset = note.offset
        self.fieldNumber = note.fieldNumber
        self.durationInSixteenth = note.durationInSixteenth
        self.isSmall = note.isSmall
    }
    
    init(type: SignsTypes, fields: [StaffField], id: Int) {
        self.id = id
        self.type = type
        self.name = type.description
        self.image = UIImage(named: type.description)
        self.offset = NotesOffset.offsets[type.description]!
        self.isSmall = false

        if (!isRest()) {
            fields.forEach { field in
                heightsInFields.append(field.upperBound + offset!)
            }
        } else {
            heightsInFields.append(fields[0].upperBound + offset!)
        }
        
        switch type {
        case .eight:
            durationInSixteenth = 2
        case .quarter:
            durationInSixteenth = 4
        case .half:
            durationInSixteenth = 8
        case .whole:
            durationInSixteenth = 16
        default:
            durationInSixteenth = 1
        }
    }
    
    init(type: SignsTypes, fields: [StaffField], fieldNumber: Int, id: Int,  isSmall: Bool) {
        self.id = id
        self.type = type
        self.isSmall = false
        if (isSmall && isNote()) {
            self.name = type.description + "Small"
        } else {
            self.name = type.description
        }
        self.image = UIImage(named: name!)!
        self.offset = NotesOffset.offsets[type.description]!
        
        if (!isRest()) {
            fields.forEach { field in
                heightsInFields.append(field.upperBound + offset!)
            }
        } else {
            heightsInFields.append(fields[0].upperBound + offset!)
        }
        self.fieldNumber = fieldNumber
    }
    
    init(id: Int) {
        self.id = id
        self.isSmall = false
    }
    
    func getDurationInSixteenth() -> Double {
        switch type {
        case .whole, .restWhole:
            if (isDotAfter) {
                return 24
            }
            return 16
        case .half, .restHalf:
            if (isDotAfter) {
                return 12
            }
            return 8
        case .quarter, .restQuarter:
            if (isDotAfter) {
                return 6
            }
            return 4
        case .eight, .restEight:
            if (isDotAfter) {
                return 3
            }
            return 2
        case .sixteenth, .restSixteenth:
            if (isDotAfter) {
                return 1.5
            }
            return 1
        default:
            return 0
        }
    }
    
    func changeIsSmallParameter() {
        var t2 = isDotAfter
        var t = isSmall
        isSmall = !isSmall
        if (isSmall) {
            image = UIImage(named: type!.description + "Small")
            name = type!.description + "Small"
        } else {
            image = UIImage(named: type!.description)
            name = type!.description
        }
    }
    
    func isSignBefore() -> Bool {
        return (isSharpBefore || isBemolBefore || isNaturalBefore)
    }
    
    func signBefore() -> SignsTypes {
        if (isBemolBefore) {
            return .bemol
        }
        if (isSharpBefore) {
            return .sharp
        }
        if (isNaturalBefore) {
            return .natural
        }
        return .none
    }
    
    func changeType(newType: SignsTypes, fields: [StaffField]) {
        if (newType != type) {
            type = newType
            name = newType.description
            image = UIImage(named: name!)!
            
            heightsInFields = []
            if (!isRest()) {
                fields.forEach { field in
                    heightsInFields.append(field.upperBound + offset!)
                }
            } else {
                isDotAfter = false
                isSharpBefore = false
                isBemolBefore = false
                isNaturalBefore = false
                fieldNumber = 1
                heightsInFields.append(fields[0].upperBound + offset!)
            }
            
            self.offset = NotesOffset.offsets[type!.description]!
            switch type {
            case .eight:
                durationInSixteenth = 2
            case .quarter:
                durationInSixteenth = 4
            case .half:
                durationInSixteenth = 8
            case .whole:
                durationInSixteenth = 16
            default:
                durationInSixteenth = 1
            }
            
        }
    }
    
    func isNote() -> Bool {
        if (["whole", "half", "quarter", "eight", "sixteenth"]
                .contains(type?.description)) {
            return true
        } else {
            return false
        }
    }
    
    func isRest() -> Bool {
        if (["restWhole", "restHalf", "restQuarter", "restEight", "restSixteenth"]
                .contains(type?.description)) {
            return true
        }
        return false
    }
    
    func isSign() -> Bool {
        if (["bemol", "sharp", "natural"]
                .contains(type?.description)) {
            return true
        }
        return false
    }
    
    func isDot() -> Bool {
        return type == .dot
    }
    
    func getMidiCode(linesOnStaff: Int) -> Int {
        let linesAdded = (linesOnStaff - 5)/2
        let fieldsAdded = linesAdded * 2
        var helperIndex = 1
        var firstLineFrequency = 77
        for i in 1...fieldsAdded {
            if (helperIndex % 7 == 0 || (helperIndex + 3) % 7 == 0) {
                firstLineFrequency += 1
            } else {
                firstLineFrequency += 2
            }
            helperIndex += 1
        }
        
        var fieldFrequency = firstLineFrequency
        for i in 1...fieldNumber! {
            if (helperIndex % 7 == 0 || (helperIndex + 3) % 7 == 0) {
                fieldFrequency -= 1
            } else {
                fieldFrequency -= 2
            }
            helperIndex += 1
        }
        
        if (isSharpBefore) {
            fieldFrequency += 1
        } else if (isBemolBefore) {
            fieldFrequency -= 1
        }
        return fieldFrequency
    }
}

enum SignsTypes: String, CaseIterable {
    case whole = "whole"
    case half = "half"
    case quarter = "quarter"
    case eight = "eight"
    case sixteenth = "sixteenth"
    case restWhole = "restWhole"
    case restHalf = "restHalf"
    case restQuarter = "restQuarter"
    case restEight = "restEight"
    case restSixteenth = "restSixteenth"
    case dot = "dot"
    case bemol = "bemol"
    case sharp = "sharp"
    case natural = "natural"
    case none = "none"
    
    var description : String {
        switch self {
        case .whole: return "whole"
        case .half: return "half"
        case .quarter: return "quarter"
        case .eight: return "eight"
        case .sixteenth: return "sixteenth"
        case .restWhole: return "restWhole"
        case .restHalf: return "restHalf"
        case .restQuarter: return "restQuarter"
        case .restEight: return "restEight"
        case .restSixteenth: return "restSixteenth"
        case .dot: return "dot"
        case .bemol: return "bemol"
        case .sharp: return "sharp"
        case .natural: return "natural"
        case .none: return "none"
        }
      }
}

struct NotesOffset {
    static let offsets: [String:CGFloat] = ["whole":0,
                                            "half":0,
                                            "quarter":0,
                                            "eight":0,
                                            "sixteenth":0,
                                            "restWhole":160,
                                            "restHalf":170,
                                            "restQuarter":202,
                                            "restEight":183,
                                            "restSixteenth":183,
                                            "bemol":4,
                                            "natural":5,
                                            "sharp":6,
                                            "dot":-2]
}
