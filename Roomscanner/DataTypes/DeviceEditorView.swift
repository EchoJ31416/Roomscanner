//
//  DeviceEditorView.swift
//  Roomscanner
//
//  Created by User on 12/7/2024.
//

import SwiftUI

struct DeviceEditorView: View {
    @Binding var onScreen: Bool
    @Environment(RoomCaptureController.self) private var captureController
    @State private var device = Device()
    @State private var deviceTag: Int = -1
    @State private var deviceOnCeiling: Bool = false
    @State private var deviceSize: Float = 0.0
    @State private var selectedDevice: Device.category = .Sensor
    @State private var conditioningType: Device.conditioningType = .window
    @State private var supplyType: Device.supplyType = .freshAirDuct
//    List {
//        Picker("Device Type", selection: Device.category) {
//            Text("Chocolate").tag(Flavor.chocolate)
//            Text("Vanilla").tag(Flavor.vanilla)
//            Text("Strawberry").tag(Flavor.strawberry)
//        }
//    }
//    Picker("Device Type", selection: Device.category) {
//        ForEach(Flavor.allCases) { flavor in
//            Text(flavor.rawValue.capitalized)
//        }
//    }
    
    var body: some View {
        @Bindable var bindableController = captureController
        VStack{
            List{
                Picker("Device Type", selection: $selectedDevice) {
                    ForEach(Device.category.allCases) { device in
                        Text(device.rawValue).tag(device)
                    }
                }
                Picker("Air Conditioning Type", selection: $conditioningType) {
                    ForEach(Device.conditioningType.allCases) { conditioner in
                        Text(conditioner.rawValue).tag(conditioner)
                    }
                }.opacity(selectedDevice == .AirConditioning ? 1 : 0)
                Picker("Air Supply Type", selection: $supplyType) {
                    ForEach(Device.supplyType.allCases) { supplier in
                        Text(supplier.rawValue).tag(supplier)
                    }
                }.opacity(selectedDevice == .AirSupply ? 1 : 0)
            }
            Button(action: {
                captureController.addDevice()
                onScreen = false
                  //  .dismi
                //showingDeviceManager.toggle()
            }, label: {
                Text("Done").font(.title2)
            })  .buttonStyle(.borderedProminent)
                .cornerRadius(40)
                .padding()
        }
    }
}

/*#Preview {
    DeviceEditorView()
}*/
