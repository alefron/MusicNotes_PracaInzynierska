//
//  CanvasView.swift
//  Music Notes
//
//  Created by Aleksandra Front on 19/11/2021.
//

import SwiftUI
import Foundation
import PencilKit

struct CanvasView {
    @Binding var staff: PKCanvasView

}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        staff.overrideUserInterfaceStyle = .light
        staff.tool = PKInkingTool(.pen, color: UIColor(hue: 0.721, saturation: 0.834, brightness: 0.53, alpha: 1.0), width: 8)
        staff.drawingPolicy = .pencilOnly
        staff.backgroundColor = UIColor.clear
      return staff
    }

  func updateUIView(_ uiView: PKCanvasView, context: Context) {
  }
}
