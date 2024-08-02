//
//  RoomscannerApp.swift
//  Roomscanner
//
//  Created by Mikael Deurell on 2022-07-13.
//

import SwiftUI

@main
struct RoomscannerApp: App {
    static let captureController = RoomCaptureController()
    @State private var devices: [Device] = []
    var body: some Scene {
        WindowGroup {
            ContentView(devices: $devices)
                .environment(RoomscannerApp.captureController)
        }
    }
}
