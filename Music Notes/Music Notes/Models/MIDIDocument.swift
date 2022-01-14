//
//  MIDIDocument.swift
//  Music Notes
//
//  Created by Aleksandra Front on 12/01/2022.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AudioToolbox
import MidiParser

struct MIDIDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.midi] }

    var name: String
    var midiData: MidiData

    init(midiData: MidiData, name: String) {
        self.midiData = midiData
        self.name = name
    }

    init(configuration: ReadConfiguration) throws {
        if (configuration.file.regularFileContents != nil) { }
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        midiData = MidiData()
        self.midiData.load(data: configuration.file.regularFileContents!)
        self.name = configuration.file.filename ?? "midi_default"
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: midiData.createData()!)
        wrapper.filename = self.name
        return wrapper
    }
    
}

