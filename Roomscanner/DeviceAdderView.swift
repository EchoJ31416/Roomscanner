//
//  DeviceAdderView.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import SwiftUI
import ARKit

struct DeviceAdderView: View {
    @Binding var onScreen: Bool
    @Environment(RoomCaptureController.self) private var captureController
    @State private var editMode = false
    @State private var device = Device()
    @State private var deviceTag: Int = -1
    @State private var deviceOnCeiling: Bool = false
    @State private var deviceWidth: Float = 0.0
    @State private var deviceHeight: Float = 0.0
    @State private var airSource: String = ""
    @State private var selectedDevice: Category = .Sensor
    @State private var selectedDirection: Directions = .NA
    @State private var conditioningType: Conditioner = .NA
    @State private var supplierType: Supplier = .NA
    @State private var doorType: Door = .NA
    @State private var windowType: Window = .NA
    @State private var openCondition: Open = .NA
    
    init(onScreen: Binding<Bool>){
        self._onScreen = onScreen
    }
//
//    init(editDevice: Device){
//
//    }
    
    var body: some View {
        @Bindable var bindableController = captureController
        VStack{
            List{
                Picker("Device Type", selection: $selectedDevice) {
                    ForEach(Category.allCases) { device in
                        Text(device.stringValue).tag(device)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack{
                    Text("Device Tag (Numerical Only):")
                    TextField("Device Tag", value: $deviceTag, format: IntegerFormatStyle())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                if (selectedDevice != .Sensor) && (selectedDevice != .Heater) {
                    Picker("Air Flow Direction", selection: $selectedDirection) {
                        ForEach(Directions.allCases) { direction in
                            Text(direction.stringValue).tag(direction)
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack{
                        Text("Device Width (cm): ")
                        TextField("Device Width", value: $deviceWidth, format: FloatingPointFormatStyle())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack{
                        Text("Device Height/Depth (cm): ")
                        TextField("Device Height/Depth", value: $deviceHeight, format: FloatingPointFormatStyle())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if ((selectedDevice == .AirExchange) || (selectedDevice == .AirSupply)) {
                    HStack{
                        Text("Air Input:")
                        TextField("Air Input", text: $airSource)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if selectedDevice == .AirConditioning {
                    Picker("Air Conditioner Type", selection: $conditioningType) {
                        ForEach(Conditioner.allCases) { conditioner in
                            Text(conditioner.stringValue).tag(conditioner)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if selectedDevice == .AirSupply {
                    Picker("Air Supply Type", selection: $supplierType) {
                        ForEach(Supplier.allCases) { supplier in
                            Text(supplier.stringValue).tag(supplier)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if selectedDevice == .DoorOpen {
                    Picker("Door Type", selection: $doorType) {
                        ForEach(Door.allCases) { door in
                            Text(door.stringValue).tag(door)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if selectedDevice == .WindowOpen {
                    Picker("Window Type", selection: $windowType) {
                        ForEach(Window.allCases) { window in
                            Text(window.stringValue).tag(window)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if ((selectedDevice == .WindowOpen) || (selectedDevice == .DoorOpen)) {
                    Picker("How Open is it?", selection: $openCondition) {
                        ForEach(Open.allCases) { open in
                            Text(open.stringValue).tag(open)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                if selectedDevice != .DoorOpen {
                    Toggle(isOn: $deviceOnCeiling){
                        Text("Is the device on the ceiling?")
                    }
                }
            }
            Button(action: {
                device = Device(
                                transform: captureController.getTransform(),
                                tag: deviceTag,
                                onCeiling: deviceOnCeiling,
                                airSource: airSource,
                                width: deviceWidth,
                                height: deviceHeight,
                                type: selectedDevice,
                                direction: selectedDirection,
                                conditioner: conditioningType,
                                supplier: supplierType,
                                window: windowType,
                                door: doorType,
                                open: openCondition)
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

