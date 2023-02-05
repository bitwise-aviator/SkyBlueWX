//
//  ErrorMessageView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI


struct ErrorMessageView: View {
    @EnvironmentObject var cockpit : Cockpit
    
    func checkForErrors() -> Errors? {
        if cockpit.reports.isEmpty {
            return .noAirportCodes
        }
        guard let activeReport = cockpit.activeReportStruct else {return .noAirportCodes}
        guard activeReport.hasData else {return .noReportFound}
        
        
        return nil
    }
    
    var boxText : String? {
        guard let foundError = checkForErrors() else {return nil}
        switch foundError {
        case .noReportFound: return "Airport \(cockpit.activeReport!) did not return a report."
        case .noAirportCodes: return "No reports available."
        }
    }
    
    @ViewBuilder
    var body: some View {
        if let errorText = boxText {
            VStack {
                Text(errorText).foregroundColor(.red)
            }.padding().border(.red, width: 5).background(Color.bicolorInv)
        } else {
            EmptyView()
        }
    }
    
}

struct ErrorMessageView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        ErrorMessageView().environmentObject(cockpit)
    }
}
