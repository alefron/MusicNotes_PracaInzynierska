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
import AudioToolbox

struct ContentView: View {
    let step: CGFloat = 20
    let linesAdded: Int = 2
    @State var staffSize = CGSize.zero
    @State var frame: CGSize = .zero
    @State private var staffHandWriting = PKCanvasView()
    @State private var staffMachineWriting = PKCanvasView()
    @State var lastPrediction: String = " "
    @State var lastPredictionImage = UIImage()
    @State var lastPredictionImage2 = UIImage()
    @State var lastPredictionNote: Note = Note(id: 0)
    @State var notesCount: Int = 0
    @State var musicSequence: MusicSequence?
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
                        self.exportMidiFile()
                    } label: {
                        Text("click me")
                    }

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
                                    LazyHStack (spacing: 0) {
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
            let image = capturedDrawing
                .image(from: capturedDrawing.bounds,
                       scale: 3.0)
            
            let imageMaximized = imageGetherer.scaleAndRender(image: image)

            let separator = NotesSeparator(entireImage: imageMaximized, entireImageXOffset: capturedDrawing.bounds.minX, entireImageYOffset: capturedDrawing.bounds.minY)
            separator.separateNotesIteratively()
            
            var wasSharpBemolNatural = false
        for_loop: for i in 0..<separator.separatedNotesWithPosition.count {
                var imageProcessed = imageGetherer.processOneNoteImage(note: separator.separatedNotesWithPosition[i].image)
                self.getPredictionOnNote(note: imageProcessed)
                
                var maxFilledFieldIndex = 2
                if (heightCalculator.isHeightMatters(predictedClassName: self.lastPrediction)) {
                    let imageToCalculateHeight = imageGetherer.getImageToCalculateHeight(uiImageWithPosition: separator.separatedNotesWithPosition[i], staffSize: staffSize)
                    maxFilledFieldIndex = self.heightCalculator.calculateHeight_TheBigestOfThreeFromBottom(imageOneNote: imageToCalculateHeight)
                } else if (lastPrediction == "dot") {
                    maxFilledFieldIndex = notesOnStaff.last?.fieldNumber ?? -1
                    if (maxFilledFieldIndex == -1) {
                        continue for_loop
                    }
                } else if (heightCalculator.isRest(predictedClassName: lastPrediction)) {
                    maxFilledFieldIndex = 1
                }
                    
                if (wasSharpBemolNatural) {
                    notesOnStaff.last!.fieldNumber = maxFilledFieldIndex
                    wasSharpBemolNatural = false
                }
                self.notesOnStaff.append(Note(type: SignsTypes(rawValue: self.lastPrediction)!, fields: staffModel.fields, fieldNumber: maxFilledFieldIndex, id: self.notesCount))
                notesCount += 1
                maxFilledFieldIndex = 2
                if (["sharp", "natural", "bemol"].contains(lastPrediction)) {
                    wasSharpBemolNatural = true
                }
            }
        }
    }
    
    func exportMidiFile() {
        var status = NewMusicSequence(&musicSequence)
        if status != OSStatus(noErr) {
            print("\(#line) bad status \(status) creating sequence")
        }
        
        var track: MusicTrack?
        status = MusicSequenceNewTrack(musicSequence!, &track)
        if status != OSStatus(noErr) {
            print("\(#line) bad status \(status) creating track")
        }
        
        var time = MusicTimeStamp(1.0)
        for index:UInt8 in 60...72 {
            var note = MIDINoteMessage(channel: 0,
                                       note: index,
                                       velocity: 64,
                                       releaseVelocity: 0,
                                       duration: 1.0 )
            MusicTrackNewMIDINoteEvent(track!, time, &note)
            time += 1
        }
        
        var musicPlayer: MusicPlayer?
        var player = NewMusicPlayer(&musicPlayer)

        player = MusicPlayerSetSequence(musicPlayer!, musicSequence)
        player = MusicPlayerStart(musicPlayer!)
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
