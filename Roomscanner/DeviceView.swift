//
//  DeviceAdderView.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import SwiftUI
import ARKit

struct DeviceView: View {
    @Environment(RoomCaptureController.self) private var captureController
    @State private var editMode = false
    @Binding var device: Device
    @Binding var onScreen: Bool
    @Binding var edit: Bool
    
    
    var body: some View {
        @Bindable var bindableController = captureController
        VStack{
            List{
                Picker("Device Type", selection: $device.type) {
                    ForEach(Category.allCases) { device in
                        Text(device.stringValue).tag(device)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack{
                    Text("Device Tag (Numerical Only):")
                    TextField("Device Tag", value: $device.tag, format: IntegerFormatStyle())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                if (device.type != .Sensor) && (device.type != .Heater) {
                    Picker("Air Flow Direction", selection: $device.direction) {
                        ForEach(Directions.allCases) { direction in
                            Text(direction.stringValue).tag(direction)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.direction = .NA})
                    HStack{
                        Text("Device Width (cm): ")
                        TextField("Device Width", value: $device.width, format: FloatingPointFormatStyle())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }.onDisappear(perform: {device.width = 0})
                    HStack{
                        Text("Device Height/Depth (cm): ")
                        TextField("Device Height/Depth", value: $device.height, format: FloatingPointFormatStyle())
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }.onDisappear(perform: {device.height = 0})
                }
                if ((device.type == .AirExchange) || (device.type == .AirSupply)) {
                    HStack{
                        Text("Air Input:")
                        TextField("Air Input", text: $device.airSource)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }.onDisappear(perform: {device.airSource = ""})
                }
                if device.type == .AirConditioning {
                    Picker("Air Conditioner Type", selection: $device.conditioner) {
                        ForEach(Conditioner.allCases) { conditioner in
                            Text(conditioner.stringValue).tag(conditioner)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.conditioner = .NA})
                }
                if device.type == .AirSupply {
                    Picker("Air Supply Type", selection: $device.supplier) {
                        ForEach(Supplier.allCases) { supplier in
                            Text(supplier.stringValue).tag(supplier)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.supplier = .NA})
                }
                if device.type == .DoorOpen {
                    Picker("Door Type", selection: $device.door) {
                        ForEach(Door.allCases) { door in
                            Text(door.stringValue).tag(door)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.door = .NA})
                }
                if device.type == .WindowOpen {
                    Picker("Window Type", selection: $device.window) {
                        ForEach(Window.allCases) { window in
                            Text(window.stringValue).tag(window)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.window = .NA})
                }
                if ((device.type == .WindowOpen) || (device.type == .DoorOpen)) {
                    Picker("How Open is it?", selection: $device.open) {
                        ForEach(Open.allCases) { open in
                            Text(open.stringValue).tag(open)
                                .foregroundStyle(.secondary)
                        }
                    }.onDisappear(perform: {device.open = .NA})
                }
                if device.type != .DoorOpen {
                    Toggle(isOn: $device.onCeiling){
                        Text("Is the device on the ceiling?")
                    }.onDisappear(perform: {device.onCeiling = false})
                }
            }
            Button(action: {
                if !edit {
                    captureController.addDevice(device: device)
                    device = Device()
                }
                onScreen = false
            }, label: {
                Text(edit ? "Edit" : "Done").font(.title2)
            })  .buttonStyle(.borderedProminent)
                .cornerRadius(40)
                .padding()
        }
    }
    
}

