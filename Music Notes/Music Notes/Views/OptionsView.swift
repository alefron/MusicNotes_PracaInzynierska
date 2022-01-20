//
//  OptionsView.swift
//  Music Notes
//
//  Created by Aleksandra Front on 11/01/2022.
//

import SwiftUI

struct OptionsView: View {
    @Environment(\.dismiss) var dismiss
    @State var staffSize = CGSize.zero
    private var originalStaffModel: StaffModel
    private var linesAdded: Int
    private var step: CGFloat
    var staffModel: StaffModel {
        return StaffModel(step: step,
                          linesAdded: linesAdded,
                          size: staffSize)
    }
    @EnvironmentObject var selectedNote: Note
    var notesToChoose: [Note] {
        var notes: [Note] = []
        var id = 0
        if (selectedNote.isRest()) {
            for type in SignsTypes.allCases {
                if (type == .restWhole ||
                    type == .restHalf ||
                    type == .restQuarter ||
                    type == .restEight ||
                    type == .restSixteenth) {
                    notes.append(
                        Note(type: type,
                             fields: staffModel.fields,
                             fieldNumber: 2,
                             id: id,
                             isSmall: true))
                    id += 1
                }
            }
        } else {
            for type in SignsTypes.allCases {
                if (type == .whole ||
                    type == .half ||
                    type == .quarter ||
                    type == .eight ||
                    type == .sixteenth) {
                    notes.append(
                        Note(type: type,
                             fields: staffModel.fields,
                             fieldNumber: 2,
                             id: id,
                             isSmall: true))
                    id += 1
                }
            }
        }
        return notes
    }
    
    init(originalStaffModel: StaffModel) {
        self.linesAdded = (originalStaffModel.linesCount - 5)/2
        self.step = originalStaffModel.step
        self.originalStaffModel = originalStaffModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Select a note's type")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(/*@START_MENU_TOKEN@*/.all, 22.0/*@END_MENU_TOKEN@*/)
                Spacer()
            }
            
            HStack {
                ScrollView(.horizontal) {
                    LazyHStack (spacing: 7) {
                        ForEach (notesToChoose, id: \.self) { note in
                            Button {
                                self.changedNoteType(type: note.type!)
                            } label: {
                                if (selectedNote.type == note.type) {
                                    NoteImage(name: note.name!,
                                              height: note.imageHeight,
                                              width: 70,
                                              isSelected: true)
                                        
                                } else {
                                    NoteImage(name: note.name!,
                                              height: note.imageHeight,
                                              width: 70)
                                }
                            }
                        }
                    }
                }
                .padding(8.0)
            }.frame(width: 555, height: selectedNote.imageHeight + 50)
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 0.001, saturation: 0.0, brightness: 1.0, opacity: 0.163)/*@END_MENU_TOKEN@*/)
            
            if (!selectedNote.isRest()) {
                HStack {
                    Text("Select a sign")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .padding(/*@START_MENU_TOKEN@*/.all, 22.0/*@END_MENU_TOKEN@*/)
                    Spacer()
                }
            
                HStack {
                    Button {
                        self.selectedNote.isSharpBefore.toggle()
                        self.selectedNote.isBemolBefore = false
                        self.selectedNote.isNaturalBefore = false
                    } label: {
                        NoteImage(name: "sharpSmall",
                                  height: notesToChoose.first!.imageHeight/1.5,
                                  width: 70,
                                  isSelected: selectedNote.isSharpBefore)
                    }
                    
                    Button {
                        self.selectedNote.isSharpBefore = false
                        self.selectedNote.isBemolBefore.toggle()
                        self.selectedNote.isNaturalBefore = false
                    } label: {
                        NoteImage(name: "bemolSmall",
                                  height: notesToChoose.first!.imageHeight/1.5,
                                  width: 70,
                                  isSelected: selectedNote.isBemolBefore)
                    }
                    
                    Button {
                        self.selectedNote.isSharpBefore = false
                        self.selectedNote.isBemolBefore = false
                        self.selectedNote.isNaturalBefore.toggle()
                    } label: {
                        NoteImage(name: "naturalSmall",
                                  height: notesToChoose.first!.imageHeight/1.5,
                                  width: 70,
                                  isSelected: selectedNote.isNaturalBefore)

                    }
                    
                    Button {
                        self.selectedNote.isDotAfter.toggle()
                        self.selectedNote.changeIsSmallParameter()
                    } label: {
                        NoteImage(name: "dotSmall",
                                  height: notesToChoose.first!.imageHeight/1.5,
                                  width: 70,
                                  isSelected: selectedNote.isDotAfter)
                    }

                }.frame(width: 455, height: selectedNote.imageHeight + 20)
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 0.001, saturation: 0.0, brightness: 1.0, opacity: 0.163)/*@END_MENU_TOKEN@*/)
                
                HStack {
                    GeometryReader { geometry in
                        ZStack {
                            Rectangle()
                                .size(width: geometry.size.width, height: geometry.size.height)
                                .padding(.horizontal, 30.0)
                                .foregroundColor(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.0, brightness: 0.993, opacity: 0.374)/*@END_MENU_TOKEN@*/)
                            
                            StaffView(geometry: geometry, step: step)
                                .padding(.horizontal, 30.0)
                                .measureSize {
                                    self.staffSize = $0
                                }
                            
                            Image(selectedNote.name!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(CGSize(width: 0, height: selectedNote.heightsInFields[selectedNote.fieldNumber! - 1] - step * 10))
                                .frame(width: selectedNote.image!.size.width * 0.8, height: staffSize.height)
                        }
                    }
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(/*@START_MENU_TOKEN@*/Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0)/*@END_MENU_TOKEN@*/)
                            .frame(width: 400, height: 200)
                        
                        HStack {
                            Button {
                                self.up()
                            } label: {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(Color(red: 0.23, green: 0.086, blue: 0.531))
                                    .scaleEffect(2)
                                    .frame(width: 38, height: 38)
                                    .padding()
                                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 0.585, saturation: 0.233, brightness: 0.966)/*@END_MENU_TOKEN@*/)
                                    .cornerRadius(30)
                            }
                            
                            Button {
                                self.down()
                            } label: {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(Color(red: 0.23, green: 0.086, blue: 0.531))
                                    .scaleEffect(2)
                                    .frame(width: 38, height: 38)
                                    .padding()
                                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 0.585, saturation: 0.233, brightness: 0.966)/*@END_MENU_TOKEN@*/)
                                    .cornerRadius(30)
                            }
                            
                            Button {
                                self.down()
                            } label: {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(Color(hue: 0.721, saturation: 1.0, brightness: 0.001, opacity: 0.552))
                                    .scaleEffect(2)
                                    .frame(width: 38, height: 38)
                                    .padding()
                                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 0.001, saturation: 0.233, brightness: 0.966)/*@END_MENU_TOKEN@*/)
                                    .cornerRadius(30)
                            }
                        }
                    }
                }
            }
            
            
            Button("sd") {
                dismiss()
            }

        }
        
    }
    
    func up() {
        if (selectedNote.fieldNumber! - 1 <= 2) {
            selectedNote.fieldNumber = 2
        } else {
            selectedNote.fieldNumber! -= 1
        }
    }
    
    func down() {
        if (selectedNote.fieldNumber! + 1 > selectedNote.heightsInFields.count - 1) {
            selectedNote.fieldNumber = selectedNote.heightsInFields.count - 1
        } else {
            selectedNote.fieldNumber! += 1
        }
    }
    
    func changedNoteType(type: SignsTypes) {
        var noteChanged = Note(type: type,
                               fields: originalStaffModel.fields,
                               fieldNumber: selectedNote.fieldNumber!,
                               id: selectedNote.id,
                               isSmall: false)
        selectedNote.type = type
        selectedNote.name = noteChanged.name
        selectedNote.image = noteChanged.image
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView(originalStaffModel: StaffModel())
            .preferredColorScheme(.light)
            .environmentObject(Note())
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}

struct NoteImage: View {
    var name: String
    var height: CGFloat
    var width: CGFloat
    var isSelected: Bool = false
    
    var body: some View {
        
        if (!isSelected) {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .padding()
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 1.0, saturation: 0.0, brightness: 1.0, opacity: 0.181)/*@END_MENU_TOKEN@*/)
        } else {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .padding()
                .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color(hue: 1.0, saturation: 0.0, brightness: 1.0, opacity: 0.558)/*@END_MENU_TOKEN@*/)
                .border(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 1.0, brightness: 0.001, opacity: 0.384)/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
        }
    }
}
