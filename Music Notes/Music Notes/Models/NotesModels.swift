//
//  NotesModels.swift
//  Music Notes
//
//  Created by Aleksandra Front on 06/01/2022.
//

import Foundation
import UIKit
import SwiftUI

class Note: Hashable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: Int
    let imageWidth: CGFloat = 50
    let imageHeight: CGFloat = 100
    let scale: CGFloat = 0.8
    var name: String?
    var image: UIImage?
    var type: SignsTypes?
    var heightsInFields: [CGFloat] = [] //a place in Y axis where the image should be drawn
    var offset: CGFloat? //count from upper line of field
    var isHeightMatters: Bool?
    var fieldNumber: Int?
    var durationInSixteenth: Int?
    
    init(type: SignsTypes, fields: [StaffField], id: Int) {
        self.id = id
        self.type = type
        self.name = type.description
        self.image = UIImage(named: type.description)
        self.offset = NotesOffset.offsets[type.description]!
        if (["whole", "half", "quarter", "eight", "sixteenth", "dot", "sharp", "bemol", "natural"].contains(type.description)) {
            self.isHeightMatters = true
        } else {
            self.isHeightMatters = false
        }
        if (isHeightMatters!) {
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
    
    init(type: SignsTypes, fields: [StaffField], fieldNumber: Int, id: Int) {
        self.id = id
        self.type = type
        self.name = type.description
        self.image = UIImage(named: type.description)!
        self.offset = NotesOffset.offsets[type.description]!
        if (["whole", "half", "quarter", "eight", "sixteenth", "dot", "sharp", "bemol", "natural"].contains(type.description)) {
            self.isHeightMatters = true
        } else {
            self.isHeightMatters = false
        }
        if (isHeightMatters!) {
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
    }
}

enum SignsTypes: String {
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
        }
      }
}

struct NotesOffset {
    static let offsets: [String:CGFloat] = ["whole":0,
                                            "half":0,
                                            "quarter":0,
                                            "eight":0,
                                            "sixteenth":0,
                                            "restWhole":0,
                                            "restHalf":0,
                                            "restQuarter":0,
                                            "restEight":0,
                                            "restSixteenth":0,
                                            "bemol":0,
                                            "natural":0,
                                            "sharp":0,
                                            "dot":0]
}
