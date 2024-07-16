//
//  DeviceEditorView.swift
//  Roomscanner
//
//  Created by User on 12/7/2024.
//

import SwiftUI
import ARKit

struct DeviceEditorView: View {
    @Binding var onScreen: Bool
    @Environment(RoomCaptureController.self) private var captureController
    @State private var device = Device()
    @State private var location: simd_float3? = nil
    @State private var deviceTag: Int = -1
    @State private var deviceOnCeiling: Bool = false
    @State private var deviceSize: Float = 0.0
    @State private var selectedDevice: Device.category = .Sensor
    @State private var conditioningType: Device.conditioningType = .NA
    @State private var supplyType: Device.supplyType = .NA
    
    var body: some View {
        @Bindable var bindableController = captureController
        VStack{
            List{
                Picker("Device Type", selection: $selectedDevice) {
                    ForEach(Device.category.allCases) { device in
                        Text(self.device.categoryConverter(category: device)).tag(device)
                    }
                }
                HStack{
                    Text("Device Tag: Integer Only")
                    TextField("Device Tag", value: $deviceTag, format: IntegerFormatStyle())
                }
                HStack{
                    Text("Device Size (cm^2): ")
                    TextField("Device Size", value: $deviceSize, format: FloatingPointFormatStyle())
                }.opacity(selectedDevice != .Sensor ? 1 : 0)
                Picker("Air Conditioner Type", selection: $conditioningType) {
                    ForEach(Device.conditioningType.allCases) { conditioner in
                        Text(self.device.conditionerConverter(conditioner: conditioner)).tag(conditioner)
                    }
                }.opacity(selectedDevice == .AirConditioning ? 1 : 0)
                Picker("Air Supply Type", selection: $supplyType) {
                    ForEach(Device.supplyType.allCases) { supplier in
                        Text(self.device.supplierConverter(supplier: supplier)).tag(supplier)
                    }
                }.opacity(selectedDevice == .AirSupply ? 1 : 0)
                Toggle(isOn: $deviceOnCeiling){
                    Text("Is the device on the ceiling?")
                }
            }
            Button(action: {
                device = Device(location: captureController.getLocation(), 
                                tag: deviceTag,
                                onCeiling: deviceOnCeiling,
                                size: deviceSize,
                                type: selectedDevice,
                                conditioner: conditioningType,
                                supplier: supplyType)
                captureController.addDevice(device: device)
                onScreen = false
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
