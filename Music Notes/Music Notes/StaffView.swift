//
//  StaffView.swift
//  Music Notes
//
//  Created by Aleksandra Front on 20/11/2021.
//

import Foundation
import SwiftUI

struct StaffView : View {
    var geometry: GeometryProxy
    var step: CGFloat
    var body: some View{
        
        //third line
        Path { path in
            let y = geometry.size.height/2
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(.black, lineWidth: 1.5)
        
        //second line
        Path { path in
            let y = geometry.size.height/2 - step
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(.black, lineWidth: 1.5)
        
        //first line
        Path { path in
            let y = geometry.size.height/2 - (2 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(.black, lineWidth: 1.5)
        
        //fourth line
        Path { path in
            let y = geometry.size.height/2 + step
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(.black, lineWidth: 1.5)
        
        //fiveth line
        Path { path in
            let y = geometry.size.height/2 + (2 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(.black, lineWidth: 1.5)
        
        //first up added
        Path { path in
            let y = geometry.size.height/2 - (3 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.817), lineWidth: 1.5)
        
        //second up added
        Path { path in
            let y = geometry.size.height/2 - (4 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.817), lineWidth: 1.5)
        
        //first down added
        Path { path in
            let y = geometry.size.height/2 + (3 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.817), lineWidth: 1.5)
        
        //second down added
        Path { path in
            let y = geometry.size.height/2 + (4 * step)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: geometry.size.width * 0.984, y: y))
        }.stroke(Color(hue: 1.0, saturation: 0.0, brightness: 0.817), lineWidth: 1.5)
        
    }
}
