//
//  ListView.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/20/22.
//

import SwiftUI

class ListViewTimer: ObservableObject {
    @Published private(set) var date = Date.now
    private static var timer: Timer?
    var timerIsRunning: Bool {
        ListViewTimer.timer != nil && ListViewTimer.timer?.isValid == true
    }
    func spawnTimer() {
        if !timerIsRunning {
            ListViewTimer.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshDate),
                                              userInfo: nil, repeats: true)
        }
    }
    func killTimer() {
        if ListViewTimer.timer != nil {ListViewTimer.timer!.invalidate()}
    }
    @objc func refreshDate() {
        date = Date.now
    }
}

struct ListView: View {
    @EnvironmentObject var cockpit: Cockpit
    @Binding var selectedTab: Views
    @StateObject var listViewTimer = ListViewTimer()
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array.init(
                repeating: GridItem(.flexible()), count: cockpit.deviceInfo.deviceType == .pad ? 4: 2), spacing: 20) {
                ForEach(cockpit.reportKeys, id: \.self) {
                    AirportTileView(selectedTab: $selectedTab, icao: $0).environmentObject(listViewTimer)
                }
            }
        }.onAppear {
            listViewTimer.spawnTimer()
        }.onDisappear {
            listViewTimer.killTimer()
        }
    }
}

#if !TESTING
struct ListView_Previews: PreviewProvider {
    static let cockpit = Cockpit()
    static var previews: some View {
        ListView(selectedTab: .constant(.list)).environmentObject(cockpit)
    }
}
#endif
