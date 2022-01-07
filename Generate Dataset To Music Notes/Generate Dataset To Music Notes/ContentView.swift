//
//  ContentView.swift
//  Generate Dataset To Music Notes
//
//  Created by Aleksandra Front on 20/11/2021.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    @State var currentScale: CGFloat = 1
    @State var frame: CGSize = .zero
    @State private var staffHandWriting = PKCanvasView()
    @State private var staffMachineWriting = PKCanvasView()
    @State private var image = UIImage()
    @State private var selectionNote: String = "quarter"
    
    @State private var openFile = false
    @State private var exportFile = false
    
    @State private var target : UIImage?
    
    @State private var documentsToExport: Array<ImageDocument> = []
    
    
    
    let notesTypes = ["whole",
    "half",
    "quarter",
    "eight",
    "sixteenth",
    "restWhole",
    "restHalf",
    "restQuarter",
    "restEight",
    "restSixteenth",
    "sharp",
    "natural",
    "bemol",
    "dot"]
    
    var body: some View {
        ZStack{
            Color(hue: 1.0, saturation: 0.0, brightness: 0.817).ignoresSafeArea()
            VStack{
                
                
                GeometryReader { geometry in
                    ZStack{
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(20, antialiased: true)
                            .shadow(radius: /*@START_MENU_TOKEN@*/12/*@END_MENU_TOKEN@*/)
                    
                        //staff
                        StaffView(geometry: geometry, step: 20)
                        
                        CanvasView(staff: $staffHandWriting)
                            .cornerRadius(20, antialiased: true)
                    }
                    .scaleEffect(currentScale)
                    .gesture(
                    MagnificationGesture()
                        .onChanged{ scale in
                            withAnimation(.spring())
                            {
                                currentScale = scale
                            }
                        }
                        
                    )
                    .gesture(
                        TapGesture()
                            .onEnded{ _ in
                                withAnimation(.spring())
                                {
                                    currentScale = 1
                                }
                            }
                    )
                    
                }
                
                HStack{
                    Spacer()
                    //export all images button
                    Button(action: {
                        self.export()
                    }, label: {
                        HStack{
                            Text("export all")
                            Image(systemName: "square.and.arrow.up.on.square.fill")
                        }
                    }).fileExporter(isPresented: $exportFile, documents: self.documentsToExport, contentType: .jpeg, onCompletion: { (result) in
                        if case .success = result {
                            print("Success")
                        } else {
                            print("Failure")
                        }
                    })
                    
                    Spacer()
                    
                    //save image button
                    Button(action: {
                        self.onSaveClick()
                    }, label: {
                        HStack{
                            Text("save and next")
                            Image(systemName: "arrowtriangle.right.fill")
                        }
                    })
                    
                    Spacer()
                    
                    //clear button
                    Button(action: {
                        self.staffHandWriting.drawing = PKDrawing()
                    }) {
                        HStack{
                            Text("clean")
                            Image(systemName: "trash")
                        }
                        
                    }
                    
                    Spacer()
                    
                }.zIndex(1)
                
                GeometryReader { geometry in
                    ZStack{
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(20, antialiased: true)
                            .shadow(radius: /*@START_MENU_TOKEN@*/12/*@END_MENU_TOKEN@*/)
                        
                        //StaffView(geometry: geometry, step: 20)
                        HStack{
                            Spacer()
            
                            VStack{
                                Text("Select note type:")
                                    .foregroundColor(Color.black)
                                
                                Picker("Select note type", selection: $selectionNote) {
                                    ForEach(notesTypes, id: \.self) {
                                                        Text($0)
                                                    }
                                }.pickerStyle(.menu)
                            }
                            
                            Spacer()
                            
                            VStack{
                                Text("Example:")
                                    .foregroundColor(Color.black)
                                Image(self.selectionNote)
                                    .border(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/3/*@END_MENU_TOKEN@*/)
                            }
                            
                            Spacer()
                        
                            if (self.image != UIImage()){
                                VStack{
                                    Text("Recent image taken:")
                                        .foregroundColor(Color.black)
                                    Image(uiImage: self.image)
                                        .border(/*@START_MENU_TOKEN@*/Color.blue/*@END_MENU_TOKEN@*/, width: 3)
                                    Button {
                                        self.deleteRecentImage()
                                    } label: {
                                        Text("delete recent")
                                        Image(systemName: "trash")
                                    }

                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func export(){
        self.exportFile.toggle()
    }
    
    func onSaveClick(){
        self.staffHandWriting.overrideUserInterfaceStyle = .light
        self.exportDrawing()
        self.staffHandWriting.drawing = PKDrawing()
        
        let timestamp = NSDate().timeIntervalSince1970
        //let newImagePath = self.saveJpg(self.image)
        self.documentsToExport.append(ImageDocument(image: self.image,
                                                    name: self.selectionNote +  String(timestamp).replacingOccurrences(of: ".", with: "-") + ".jpg"))
    }
    
    func deleteRecentImage(){
        self.documentsToExport.removeLast()
        self.image = UIImage()
    }
    
    func exportDrawing(){
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            let capturedDrawing = staffHandWriting.drawing
            let image = capturedDrawing.image(from: capturedDrawing.bounds, scale: 3.0)
            let drawingX = image.size.width
            let drawingY = image.size.height
            
            let desirableDimension: CGFloat = 299
            
            var imageX: CGFloat
            var imageY: CGFloat
            
            if (drawingX > drawingY){
                imageX = desirableDimension
                imageY = (drawingY/drawingX) * desirableDimension
            }
            else{
                imageY = desirableDimension
                imageX = (drawingX/drawingY) * desirableDimension
            }
            let newSize = CGSize(width: imageX, height: imageY)
            let rect = CGRect(origin: .zero, size: newSize)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                image.draw(in: rect)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            
            let image299x299 = self.drawNoteOn299x299Image(note: newImage!)
            
            self.image = image299x299
        }
    
        
    }
    
    func drawNoteOn299x299Image(note: UIImage) -> UIImage{
        var rect = CGRect(origin: .zero, size: CGSize(width: 299, height: 299))
        let xPosition = CGFloat.random(in: 0..<300 - note.size.width)
        let yPosition = CGFloat.random(in: 0..<300 - note.size.height)
        rect.origin = CGPoint(x: xPosition, y: yPosition)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), false, 1.0)
        note.draw(at: rect.origin)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        return newImage!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad (9th generation)")
.previewInterfaceOrientation(.landscapeLeft)
    }
}
