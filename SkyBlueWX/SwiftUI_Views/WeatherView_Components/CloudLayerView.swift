//
//  CloudLayerView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/5/23.
//

import SwiftUI

struct CloudLayerView: View {
    @EnvironmentObject var cockpit : Cockpit
    let layerIndex : Int?
    
    var cloudData : CloudLayer? {
        guard let clouds = cockpit.activeReportStruct?.clouds else {return nil}
        guard let idx = layerIndex else {return nil}
        if idx >= clouds.startIndex && idx < clouds.endIndex {
            return clouds[idx]
        } else {
            return nil
        }
    }
    
    var cloudCoverageIcon : AnyView {
        get {
            let noDataIcon = AnyView(GeometryReader {g in ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 5)
                Text("?").font(.system(size: min(g.size.height,g.size.width,30) * 0.7))
            }.frame(maxWidth: 30, maxHeight: 30)})
            // Is this one really used here??
            let clearIcon = AnyView(ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 5)
            }.frame(maxWidth: 30, maxHeight: 30))
            let fewIcon = AnyView(ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 5)
                Circle().trim(from: 0.0, to: 0.5).rotation(Angle(degrees: -90)).clipShape(Circle().trim(from: 0.0, to: 0.5).rotation(Angle(degrees:180)))
            }.frame(maxWidth: 30, maxHeight: 30))
            let scatteredIcon = AnyView(ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 5)
                Circle().trim(from: 0.0, to: 0.5).rotation(Angle(degrees: -90))
            }.frame(maxWidth: 30, maxHeight: 30))
            let brokenIcon = AnyView(ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 5)
                Circle().trim(from: 0.0, to: 0.5).rotation(Angle(degrees: -90))
                Circle().trim(from: 0.0, to: 0.5)
            }.frame(maxWidth: 30, maxHeight: 30))
            let overcastIcon = AnyView(ZStack {
                Circle().strokeBorder(  Color.bicolor, lineWidth: 20).background(Circle().fill(Color.bicolor))
            }.frame(maxWidth: 30, maxHeight: 30))
            let obscuredIcon = AnyView(GeometryReader { g in ZStack {
                Circle().strokeBorder(Color.bicolor, lineWidth: 20).background(Circle().fill(Color.bicolor))
                Text("!").foregroundColor(Color.bicolorInv).font(.system(size: min(g.size.height,g.size.width,30) * 0.7))
            }.frame(maxWidth: 30, maxHeight: 30)})
            
            guard let thisLayer = cloudData else {
                return noDataIcon
            }
            switch(thisLayer.cover) {
            case .few: return fewIcon
            case .scattered: return scatteredIcon
            case .broken: return brokenIcon
            case .overcast: return overcastIcon
            case .obscured: return obscuredIcon
            }
        }
    }
    
    var isCeiling : Bool {
        guard let thisLayer = cloudData else {return false}
        guard let ceilingLayer = cockpit.activeReportStruct!.ceilingLayer else {return false}
        return thisLayer == ceilingLayer
    }
    
    var cloudZText : String {
        guard let thisLayer = cloudData else {return "-----"}
        return String(thisLayer.height)
    }
    
    var cloudCoverText : String {
        guard let thisLayer = cloudData else {return "---"}
        return thisLayer.cover.rawValue
    }
    
    @ViewBuilder
    var body: some View {
        ZStack {
            Path() {path in
                path.move(to: CGPoint(x: 0, y: 25))
                path.addLine(to: CGPoint(x: 400, y: 25))
            }.stroke(.red, style: StrokeStyle(lineWidth: 3, dash: [5]))
            GeometryReader {g in
                HStack {
                    cloudCoverageIcon
                    Text(cloudCoverText).font(.system(size: min(g.size.height, 30) * 0.7))
                    Text(cloudZText).font(.system(size: min(g.size.height, 30) * 0.7))
                }.frame(maxHeight: 30).padding(10).background(Color.grayBackground).border(isCeiling ? Color.bicolorCaution : .clear, width: 3)
            }
        }
    }
}

struct CloudLayerView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        CloudLayerView(layerIndex: nil).environmentObject(cockpit)
    }
}
