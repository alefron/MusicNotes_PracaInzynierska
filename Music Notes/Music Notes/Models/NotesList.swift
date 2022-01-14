//
//  NotesList.swift
//  Music Notes
//
//  Created by Aleksandra Front on 11/01/2022.
//

import Foundation

class NotesList: ObservableObject {
    @Published var notes: [Note]
    
    init() {
        self.notes = []
    }
}
