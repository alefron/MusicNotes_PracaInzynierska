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
import MidiParser

struct ContentView: View {
    @State var globalNoteId = 200
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
    @State var musicPlayer: MusicPlayer?
    @State var isOptionsPresented = false
    @State var exportFile = false
    @State var midiData = MidiData()
    @State var documentToExport: MIDIDocument?
    
    var red = Color(red: 0.6, green: 0, blue: 0.12)
    var blue = Color(hue: 0.695, saturation: 0.926, brightness: 0.52)
    var grey = Color(red: 0.60, green: 0.60, blue: 0.60)
    var white = Color(hue: 1.0, saturation: 0.0, brightness: 1.0)
    var lightGrey = Color(red: 0.70, green: 0.70, blue: 0.70)
    var lightRed = Color(red: 0.90, green: 0.70, blue: 0.70)
    var noteColor = UIColor(hue: 0.721, saturation: 0.834, brightness: 0.53, alpha: 1.0)
    @State var staffBackground = Color(hue: 1.0, saturation: 0.0, brightness: 1.0)
    @State var trashBackground = Color(red: 0.60, green: 0.60, blue: 0.60)
    @State var isTrashMode = false
    var staffModel: StaffModel {
        return StaffModel(step: step, linesAdded: linesAdded, size: staffSize)
    }
    var heightCalculator: HeightCalculator {
        return HeightCalculator(staffModel: self.staffModel, prediction: self.lastPrediction)
    }
    @State var notesOnStaff: [Note] = []
    @StateObject var selectedNote: Note = Note()
    @State var selectedNoteIdx: Int = -1
    
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
                        
                        VStack {
                            HStack (spacing: 14) {
                                Button {
                                    self.changeToPen()
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(lightGrey)
                                            .cornerRadius(18)
                                            .frame(width: 40, height: 40)
                                            .shadow(radius: 12)
                                        
                                        Image(systemName: "pencil.and.outline")
                                            .scaleEffect(1.6)
                                            .foregroundColor(blue)
                                    }
                                }
                                
                                Button {
                                    self.changeToEraser()
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(lightGrey)
                                            .cornerRadius(20)
                                            .frame(width: 40, height: 40)
                                            .shadow(radius: 12)
                                        
                                        Image(systemName: "pencil.slash")
                                            .scaleEffect(1.6)
                                            .foregroundColor(blue)
                                    }
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding([.top, .leading], 20.0)
                        
                        
                    }
                }
                
                HStack(spacing: 22) {
                    if (!notesOnStaff.isEmpty) {
                        Button {
                            self.onPlayClick()
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(grey)
                                    .cornerRadius(20)
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 12)
                                
                                Image(systemName: "play.circle")
                                    .scaleEffect(2)
                                    .foregroundColor(red)
                            }
                        }
                        
                        Button {
                            self.onPauseClick()
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(grey)
                                    .cornerRadius(20)
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 12)

                                Image(systemName: "stop.circle")
                                    .scaleEffect(2)
                                    .foregroundColor(blue)
                                
                            }
                        }
                    }
                    
                    Button {
                        self.onTrashClicked()
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(trashBackground)
                                .cornerRadius(20)
                                .frame(width: 50, height: 50)
                                .shadow(radius: 12)

                            Image(systemName: "trash")
                                .scaleEffect(2)
                                .foregroundColor(red)
                            
                        }
                    }
                        
                    if (!notesOnStaff.isEmpty) {
                        Button(action: {
                            self.saveFile()
                        }, label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(red)
                                    .cornerRadius(20)
                                    .frame(width: 100, height: 50)
                                    .shadow(radius: 12)
                                
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(white)
                                    Text("save")
                                        .font(.title2)
                                        .foregroundColor(white)
                                }
                            }
                        })
                        .fileExporter(isPresented: $exportFile, document: self.documentToExport, contentType: .midi, onCompletion: { (result) in
                            if case .success = result {
                                print("Success")
                            } else {
                                print("Failure")
                            }
                        })
                        
                    }
                
                    Button {
                        self.onConvertClicked()
                        self.cleanStaff()
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(blue)
                                .cornerRadius(20)
                                .frame(width: 100, height: 50)
                                .shadow(radius: 12)
                            
                            Text("convert")
                                .font(.title2)
                                .foregroundColor(white)
                        }
                        
                    }
                }
                
                GeometryReader { geometry in
                    ZStack{
                        Rectangle()
                            .foregroundColor(staffBackground)
                            .cornerRadius(20, antialiased: true)
                        
                        //staff
                        StaffView(geometry: geometry, step: step)
                        HStack {
                            ScrollView(.horizontal, showsIndicators: true) {
                                ScrollViewReader { value in
                                    LazyHStack (spacing: 0) {
                                        ForEach (0..<notesOnStaff.count, id: \.self) { index in
                                                Image(notesOnStaff[index].name!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .offset(CGSize(width: 0, height: notesOnStaff[index].heightsInFields[notesOnStaff[index].fieldNumber! - 1] - step * 10))
                                                    .frame(width: notesOnStaff[index].image!.size.width * 0.8, height: staffSize.height)
                                                    .onTapGesture {
                                                        if (notesOnStaff[index].isSign()) {
                                                            selectedNoteIdx = index + 1
                                                        } else if(notesOnStaff[index].isDot()) {
                                                            selectedNoteIdx = index - 1
                                                        } else {
                                                            selectedNoteIdx = index
                                                        }
                                                        
                                                        if (isTrashMode) {
                                                            self.removeNoteFromStaff()
                                                        } else {
                                                            self.selectedNote.type = notesOnStaff[selectedNoteIdx].type
                                                            self.selectedNote.name = notesOnStaff[selectedNoteIdx].name
                                                            self.selectedNote.fieldNumber = notesOnStaff[selectedNoteIdx].fieldNumber
                                                            self.selectedNote.image = notesOnStaff[selectedNoteIdx].image
                                                            self.selectedNote.durationInSixteenth = notesOnStaff[selectedNoteIdx].durationInSixteenth
                                                            self.isOptionsPresented = true
                                                            self.selectedNote.heightsInFields = notesOnStaff[selectedNoteIdx].heightsInFields
                                                            self.selectedNote.isSharpBefore = notesOnStaff[selectedNoteIdx].isSharpBefore
                                                            self.selectedNote.isBemolBefore = notesOnStaff[selectedNoteIdx].isBemolBefore
                                                            self.selectedNote.isDotAfter = notesOnStaff[selectedNoteIdx].isDotAfter
                                                            self.selectedNote.isNaturalBefore = notesOnStaff[selectedNoteIdx].isNaturalBefore
                                                            self.selectedNoteIdx = selectedNoteIdx
                                                            self.selectedNote.isSmall = notesOnStaff[selectedNoteIdx].isSmall
                                                        }
                                                    }
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
        .sheet(isPresented: $isOptionsPresented,
                onDismiss: onDissmis) {
            OptionsView(originalStaffModel: staffModel)
                .environmentObject(selectedNote)
          
            
            
         }
    }
    
    func onDissmis() {
        if (!notesOnStaff[selectedNoteIdx].isSignBefore() && selectedNote.isSignBefore()) {
            var signBefore = selectedNote.signBefore()
            notesOnStaff.insert(Note(type: signBefore,
                                     fields: staffModel.fields,
                                     fieldNumber: selectedNote.fieldNumber!,
                                     id: globalNoteId,
                                     isSmall: false),
                                at: selectedNoteIdx)
            selectedNoteIdx += 1
            globalNoteId += 1
        } else if (notesOnStaff[selectedNoteIdx].isSignBefore() && selectedNote.isSignBefore()) {
            var signBefore = selectedNote.signBefore()
            notesOnStaff[selectedNoteIdx - 1].changeType(newType: signBefore,
                                                         fields: staffModel.fields)
            notesOnStaff[selectedNoteIdx - 1].fieldNumber! = selectedNote.fieldNumber!
        } else if (notesOnStaff[selectedNoteIdx].isSignBefore() && !selectedNote.isSignBefore()) {
            notesOnStaff.remove(at: selectedNoteIdx - 1)
            selectedNoteIdx -= 1
        }
        

        if (!notesOnStaff[selectedNoteIdx].isDotAfter && selectedNote.isDotAfter) {
            if (selectedNoteIdx == notesOnStaff.count - 1) {
                notesOnStaff.append(Note(type: .dot,
                                         fields: staffModel.fields,
                                         fieldNumber: selectedNote.fieldNumber!,
                                         id: globalNoteId,
                                         isSmall: false))
                notesOnStaff[notesOnStaff.count - 2].changeIsSmallParameter()
            } else {
                notesOnStaff.insert(Note(type: .dot,
                                         fields: staffModel.fields,
                                         fieldNumber: selectedNote.fieldNumber!,
                                         id: globalNoteId,
                                         isSmall: false),
                                    at: selectedNoteIdx + 1)
            }
            
            globalNoteId += 1
        } else if (notesOnStaff[selectedNoteIdx].isDotAfter && !selectedNote.isDotAfter) {
            notesOnStaff.remove(at: selectedNoteIdx + 1)
            notesOnStaff[selectedNoteIdx].changeIsSmallParameter()
        } else if (notesOnStaff[selectedNoteIdx].isDotAfter && selectedNote.isDotAfter) {
            notesOnStaff[selectedNoteIdx + 1].fieldNumber! = selectedNote.fieldNumber!
        }
        
        notesOnStaff[selectedNoteIdx] = Note(type: selectedNote.type!,
                                             fields: staffModel.fields,
                                             fieldNumber: selectedNote.fieldNumber!,
                                             id: globalNoteId,
                                             isSmall: selectedNote.isSmall)
        notesOnStaff[selectedNoteIdx].isNaturalBefore = selectedNote.isNaturalBefore
        notesOnStaff[selectedNoteIdx].isBemolBefore = selectedNote.isBemolBefore
        notesOnStaff[selectedNoteIdx].isDotAfter = selectedNote.isDotAfter
        notesOnStaff[selectedNoteIdx].isSharpBefore = selectedNote.isSharpBefore
        globalNoteId += 1
    }
    
    func onConvertClicked() {
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            //IMAGE PREPARATION
            var imageGetherer = ImageGetherer(handwritingArea: self.staffHandWriting)
            let capturedDrawing = staffHandWriting.drawing
            let image = capturedDrawing
                .image(from: capturedDrawing.bounds,
                       scale: 3.0)
            
            let imageMaximized = imageGetherer.scaleAndRender(image: image)
            //split an image
            let separator = NotesSeparator(entireImage: imageMaximized,
                                           entireImageXOffset: capturedDrawing.bounds.minX,
                                           entireImageYOffset: capturedDrawing.bounds.minY)
            separator.separateNotesIteratively()
            
            var wasSharpBemolNatural = false
            //for every single note
        for_every_note: for i in 0..<separator.separatedNotesWithPosition.count {
            var imageProcessed = imageGetherer.processOneNoteImage(
                note: separator.separatedNotesWithPosition[i].image)
            
            //GET PREDICTION
            self.getPredictionOnNote(note: imageProcessed)
            
            let sign = Note(type: SignsTypes(rawValue: self.lastPrediction)!, fields: staffModel.fields, fieldNumber: 1, id: globalNoteId, isSmall: false)
                
            //GET HEIGHT ON THE STAFF

            if (sign.isNote()) {
                let imageToCalculateHeight = imageGetherer
                    .getImageToCalculateHeight(
                        uiImageWithPosition: separator.separatedNotesWithPosition[i],
                        staffSize: staffSize)
                
                sign.fieldNumber = self.heightCalculator
                    .calculateHeight_TheBigestOfThreeFromBottom(imageOneNote: imageToCalculateHeight)
                
            } else if (sign.isDot()) {
                //get height of last sign
                sign.fieldNumber = notesOnStaff.last?.fieldNumber ?? -1
                if (sign.fieldNumber == -1) {
                    //there is no sign before
                    continue for_every_note
                }
                if (notesOnStaff.last?.isSign() ?? true || notesOnStaff.last?.isDot() ?? true || notesOnStaff.last?.isRest() ?? true) {
                    //last sign is sign rest or dot or do not exist
                    continue for_every_note
                } else {
                    notesOnStaff.last!.isDotAfter = true
                    notesOnStaff.last!.changeIsSmallParameter()
                }
            }

            if (sign.isSign()) {
                if (notesOnStaff.last?.isSign() ?? false) {
                    //last sign is sign
                    notesOnStaff.remove(at: notesOnStaff.count - 1)
                }
            }
            
            if (wasSharpBemolNatural && sign.isNote()) {
                notesOnStaff.last!.fieldNumber = sign.fieldNumber
                switch notesOnStaff.last!.type {
                case .natural:
                    sign.isNaturalBefore = true
                case .sharp:
                    sign.isSharpBefore = true
                case .bemol:
                    sign.isBemolBefore = true
                default:
                    break
                }
                wasSharpBemolNatural = false
            }
            
            self.notesOnStaff.append(sign)
            
            if (i == separator.separatedNotesWithPosition.count - 1) {
                //last sign to add
                var firstIndToRemove = -1
                if (!notesOnStaff.isEmpty) {
                    for j in (0..<notesOnStaff.count).reversed() {
                        if (notesOnStaff[j].isSign()) {
                            //sharp, natural and bemol at the end are not allowed
                            firstIndToRemove = j
                        } else  {
                            break
                        }
                    }
                    if (firstIndToRemove != -1) {
                        while (firstIndToRemove < notesOnStaff.count) {
                            notesOnStaff.remove(at: firstIndToRemove)
                        }
                    }
                }
            }

            if (sign.isSign()) {
                wasSharpBemolNatural = true
            }
            
            globalNoteId += 1
            notesCount += 1
            
            }
        }
    }
    
    func saveFile() {
        midiData = MidiData()
        let track = midiData.addTrack()
        var timeStamp: Double = 0.0
        notesOnStaff.forEach({ element in
            if (element.isNote()) {
                track.add(note: MidiNote(timeStamp: timeStamp,
                                         duration: Float(element.getDurationInSixteenth())/2,
                                         note: UInt8(element.getMidiCode(linesOnStaff: staffModel.linesCount)+4),
                                         velocity: 90,
                                         channel: 0))
            } else if (element.isRest()) {
                track.add(note: MidiNote(timeStamp: timeStamp,
                                         duration: Float(element.getDurationInSixteenth())/2,
                                         note: 64,
                                         velocity: 0,
                                         channel: 0))
            }
            timeStamp += element.getDurationInSixteenth()/2
        })
        let timestampDate = NSDate().timeIntervalSince1970
        let timetampToName = String(timestampDate).replacingOccurrences(of: ".", with: "-")
        self.documentToExport = MIDIDocument(midiData: midiData,
                                             name: "midi_\(timetampToName).MIDI")
        self.exportFile = true
    }
    
    func onTrashClicked() {
        self.isTrashMode.toggle()
        if (isTrashMode) {
            self.trashBackground = lightRed
            self.staffBackground = lightRed
        } else {
            self.trashBackground = grey
            self.staffBackground = white
        }
    }
    
    func removeNoteFromStaff() {
        if (notesOnStaff[selectedNoteIdx].isDotAfter) {
            notesOnStaff.remove(at: selectedNoteIdx + 1)
        }
        var wasSign = false
        if (notesOnStaff[selectedNoteIdx].isSignBefore()) {
            wasSign = true
        }
        notesOnStaff.remove(at: selectedNoteIdx)
        if (wasSign) {
            notesOnStaff.remove(at: selectedNoteIdx - 1)
        }
    }
    
    func changeToEraser() {
        staffHandWriting.tool = PKEraserTool(.bitmap)
    }
    
    func changeToPen() {
        staffHandWriting.tool = PKInkingTool(.pen,
                                             color: noteColor,
                                             width: 8)
    }
    
    func onPlayClick() {
        self.makeMidiStructureToPlay()
        NewMusicPlayer(&musicPlayer)
        MusicPlayerSetSequence(musicPlayer!, musicSequence)
        MusicPlayerStart(musicPlayer!)
    }
    
    func onPauseClick() {
        if (musicPlayer != nil) {
            MusicPlayerStop(musicPlayer!)
        }
    }
    
    func makeMidiStructureToPlay() {
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
        notesOnStaff.forEach({ element in
            if (element.isNote()) {
                var note = MIDINoteMessage(channel: 0,
                                           note: UInt8(element.getMidiCode(linesOnStaff: staffModel.linesCount)+4),
                                           velocity: 90,
                                           releaseVelocity: 0,
                                           duration: Float(element.getDurationInSixteenth()/2))
                MusicTrackNewMIDINoteEvent(track!, time, &note)
                time += Double(element.getDurationInSixteenth()/2)
            } else if (element.isRest()) {
                var note = MIDINoteMessage(channel: 0,
                                           note: 64,
                                           velocity: 0,
                                           releaseVelocity: 0,
                                           duration: Float(element.getDurationInSixteenth()/2))
                MusicTrackNewMIDINoteEvent(track!, time, &note)
                time += Double(element.getDurationInSixteenth()/2)
            }
        })
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
