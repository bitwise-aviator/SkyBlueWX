//
//  WeatherLabelSmallView.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/4/23.
//

import SwiftUI


struct WeatherLabelSmallView: View {
    @EnvironmentObject var cockpit : Cockpit
    @State var reportAge : (hours: Int, minutes: Int)? = nil
    
    let updateAgeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func updateAge() {
        reportAge = cockpit.activeReportStruct?.timeSinceReport
    }
    
    var text : String {
        cockpit.activeReport ?? "----"
    }
    
    var subText : String {
        cockpit.activeReportStruct?.airport?.name ?? "-----"
    }
    
    var reportAgeText : String {
        guard let age = reportAge else { return "--h--m"}
        return "\(String(age.hours))h\(String(format: "%02d", age.minutes))m ago"
    }
    
    var reportAgeColor : Color {
        guard let age = reportAge else { return .bicolor}
        return age.hours >= 1 ? Color.bicolorCaution : Color.bicolor
    }
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            if cockpit.deviceInfo.deviceType == .pad {
                Text(text).foregroundColor(.bicolor).font(.system(size: 16)).fontWeight(.bold) + Text("(\(reportAgeText))").foregroundColor(reportAgeColor)
                Text(subText).foregroundColor(.bicolor)
            } else {
                Text(text).foregroundColor(.bicolor).font(.system(size: 16)).fontWeight(.bold)
                Text(reportAgeText).foregroundColor(reportAgeColor)
            }
        }.onAppear() {
            updateAge()
        }.onReceive(updateAgeTimer) {_ in
            updateAge()
        }.onChange(of: cockpit.activeReport) {_ in
            updateAge()
        }.onDisappear() {
            updateAgeTimer.upstream.connect().cancel()
            print("View removed")
        }
    }
}

struct WeatherLabelSmallView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        WeatherLabelSmallView().environmentObject(cockpit)
    }
}
