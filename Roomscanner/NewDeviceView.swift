//
//  NewDeviceView.swift
//  Roomscanner
//
//  Created by User on 2/8/2024.
//

import SwiftUI

struct NewDeviceView: View {
    @Environment(RoomCaptureController.self) private var captureController
    @State private var newDevice = Device.emptyDevice
    @Binding var devices: [Device]
    @Binding var onScreen: Bool
    
    var body: some View {
        NavigationStack {
            DeviceView(device: $newDevice)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            onScreen = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            newDevice.transform = captureController.getTransform()
                            devices.append(newDevice)
                            onScreen = false
                        }
                    }
                }
        }
    }
}


