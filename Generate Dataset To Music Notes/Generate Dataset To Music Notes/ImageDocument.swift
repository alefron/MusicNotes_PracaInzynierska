//
//  ImageDocument.swift
//  Generate Dataset To Music Notes
//
//  Created by Aleksandra Front on 20/11/2021.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.jpeg] }

    var image: UIImage
    var name: String

    init(image: UIImage?, name: String) {
        self.image = image ?? UIImage()
        self.name = name
    }
    
    init(url: URL?, name: String){
        
        //let fileManager = FileManager.default
        self.image = UIImage(contentsOfFile: url?.path ?? "") ?? UIImage()
        self.name = name
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = UIImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
        self.name = configuration.file.filename ?? "image_default"
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(regularFileWithContents: image.jpegData(compressionQuality: 1.0)!)
        wrapper.filename = self.name
        return wrapper
    }
    
}
