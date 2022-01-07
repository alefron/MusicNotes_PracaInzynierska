//
//  ContentView.swift
//  Music Notes
//
//  Created by Aleksandra Front on 19/11/2021.
//

import SwiftUI
import PencilKit
import CoreML
import Vision

struct ContentView: View {
    let step: CGFloat = 20
    let linesAdded: Int = 2
    @State var staffSize = CGSize.zero
    @State var frame: CGSize = .zero
    @State private var staffHandWriting = PKCanvasView()
    @State private var staffMachineWriting = PKCanvasView()
    @State var lastPrediction: String = " "
    @State var lastPredictionImage = UIImage()
    @State var lastPredictionNote: Note = Note(id: 0)
    @State var notesCount: Int = 0
    var staffModel: StaffModel {
        return StaffModel(step: step, linesAdded: linesAdded, size: staffSize)
    }
    var heightCalculator: HeightCalculator {
        return HeightCalculator(staffModel: self.staffModel, prediction: self.lastPrediction)
    }
    @State var notesOnStaff: [Note] = []
    
    var body: some View {
        ZStack{
            Color(hue: 1.0, saturation: 0.0, brightness: 0.817).ignoresSafeArea()
            VStack{
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(20, antialiased: true)
                            .shadow(radius: /*@START_MENU_TOKEN@*/12/*@END_MENU_TOKEN@*/)
                        
                        //staff
                        StaffView(geometry: geometry, step: step).measureSize {
                            self.staffSize = $0
                        }
                        
                        CanvasView(staff: $staffHandWriting)
                            .cornerRadius(20, antialiased: true)
                    }
                }
                
                HStack {
                    Button {
                        self.onConvertClicked()
                        self.cleanStaff()
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(hue: 0.695, saturation: 0.926, brightness: 0.52))
                                .cornerRadius(20)
                                .frame(width: 100, height: 50)
                                .shadow(radius: 12)
                            
                            Text("convert")
                                .font(.title2)
                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 1.0))
                        }
                        
                    }
                }
                
                GeometryReader { geometry in
                    ZStack{
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(20, antialiased: true)
                        
                        //staff
                        StaffView(geometry: geometry, step: step)
                        HStack {
                            ScrollView(.horizontal, showsIndicators: true) {
                                ScrollViewReader { value in
                                    LazyHStack {
                                        ForEach (notesOnStaff, id: \.self) { note in
                                                Image(note.name!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .offset(CGSize(width: 0, height: note.heightsInFields[note.fieldNumber! - 1] - step * 10))
                                                    .frame(width: note.image!.size.width * 0.8, height: staffSize.height)
                                        }
                                    }
                                    .onChange(of: notesOnStaff.count) { _ in
                                        if (notesOnStaff.count > 0) {
                                            value.scrollTo(notesOnStaff[notesOnStaff.endIndex - 1])
                                        }
                                    }
                                }
                            }
                        }.frame(width: staffSize.width, height: staffSize.height)
                        
                    }
                }
            }
        }
    }
    
    func onConvertClicked() {
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            var imageGetherer = ImageGetherer(handwritingArea: self.staffHandWriting)
            let capturedDrawing = staffHandWriting.drawing
            var image = capturedDrawing.image(from: capturedDrawing.bounds, scale: 3.0)
            
            image = imageGetherer.processOneNoteImage(note: image)
            
            self.lastPredictionImage = image
            
            self.getPredictionOnNote(note: image)
            
            let imageToCalculateHeight = imageGetherer.getImageToCalculateHeight(drawingOneNote: capturedDrawing, staffSize: self.staffSize)
            
            self.lastPredictionImage = imageToCalculateHeight
            var maxFilledFieldIndex = 0
            if (heightCalculator.isHeightMatters(predictedClassName: self.lastPrediction)) {
                maxFilledFieldIndex = self.heightCalculator.calculateHeight_TheBigestOfThreeFromBottom(imageOneNote: imageToCalculateHeight)
            }
            
            self.notesOnStaff.append(Note(type: SignsTypes(rawValue: self.lastPrediction)!, fields: staffModel.fields, fieldNumber: maxFilledFieldIndex, id: self.notesCount))
            notesCount += 1
        }
    }
    
    func getPredictionOnNote(note: UIImage) {
        do {
            let model = try VNCoreMLModel(for: MusicNotesPredictor().model)
            let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
            let handler = VNImageRequestHandler(cgImage: note.cgImage!)
            try! handler.perform([request])

            func resultsMethod(request: VNRequest, error: Error?) {
                guard let results = request.results as? [VNClassificationObservation]
                    else { fatalError("huh") }
                var maxConfidence = results[0].confidence
                self.lastPrediction = results[0].identifier
                for classification in results {
                    if (classification.confidence > maxConfidence) {
                        self.lastPrediction = classification.identifier
                    }
                }
            }
        } catch {
            
        }
    }
    
    func cleanStaff() {
        self.staffHandWriting.drawing = PKDrawing()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad (9th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
