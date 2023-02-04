//
//  WindSockView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/2/23.
//

import SwiftUI

enum WindSockIcon : String {
    case kt00 = "WindSock00kt"
    case kt03 = "WindSock03kt"
    case kt06 = "WindSock06kt"
    case kt09 = "WindSock09kt"
    case kt12 = "WindSock12kt"
    case kt15 = "WindSock15kt"
}



struct WindSockView: View {
    @EnvironmentObject var cockpit : Cockpit
    var windSockIcon : WindSockIcon {
        get {
            guard let _ = cockpit.activeReportStruct else {return .kt00}
            switch cockpit.activeReportStruct!.wind.speed {
            case 15...: return .kt15
            case 12..<15: return .kt12
            case 9..<12: return .kt09
            case 6..<9: return .kt06
            case 3..<6: return .kt03
            default: return .kt00
            }
        }
    }
    /*@State var windSockIcon : WindSockIcon = .kt00
    
    func updateWindSock() {
        guard let _ = cockpit.activeReportStruct else {windSockIcon = .kt00; return}
        switch (cockpit.activeReportStruct!.wind.speed) {
        case 15...: windSockIcon = .kt15
        case 12..<15: windSockIcon = .kt12
        case 9..<12: windSockIcon = .kt09
        case 6..<9: windSockIcon = .kt06
        case 3..<6: windSockIcon = .kt03
        default: windSockIcon = .kt00
        }
    }*/
    
    var maxDimension = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    var body: some View {
        Image(windSockIcon.rawValue).resizable().frame(width: maxDimension * 0.1, height: maxDimension * 0.1)/*.onReceive(cockpit, perform: updateWindSock)*/
    }
}

struct WindSockView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WindSockView().environmentObject(cockpit)
    }
}