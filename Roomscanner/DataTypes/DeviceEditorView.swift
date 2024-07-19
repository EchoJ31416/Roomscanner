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
    @State private var deviceTag: Int = -1
    @State private var deviceOnCeiling: Bool = false
    @State private var deviceWidth: Float = 0.0
    @State private var deviceHeight: Float = 0.0
    @State private var selectedDevice: Device.category = .Sensor
    @State private var selectedDirection: Device.directions = .NA
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
                Picker("Air Flow Direction", selection: $selectedDirection) {
                    ForEach(Device.directions.allCases) { direction in
                        Text(self.device.directionConverter(direction: direction)).tag(direction)
                    }
                }
                HStack{
                    Text("Device Tag: Integer Only")
                    TextField("Device Tag", value: $deviceTag, format: IntegerFormatStyle())
                }
                HStack{
                    Text("Device Width (cm): ")
                    TextField("Device Width", value: $deviceWidth, format: FloatingPointFormatStyle())
                }.opacity(selectedDevice != .Sensor ? 1 : 0)
                HStack{
                    Text("Device Height/Depth (cm): ")
                    TextField("Device Height/Depth", value: $deviceHeight, format: FloatingPointFormatStyle())
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
                device = Device(
                                transform: captureController.getTransform(),
                                tag: deviceTag,
                                onCeiling: deviceOnCeiling,
                                width: deviceWidth,
                                height: deviceHeight,
                                type: selectedDevice,
                                direction: selectedDirection,
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
