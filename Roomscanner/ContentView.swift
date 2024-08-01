//
//  ContentView.swift
//  Roomscanner
//
//  Created by Mikael Deurell on 2022-07-13.
//

import SwiftUI
import RoomPlan
import ARKit
import _SpriteKit_SwiftUI
import _SceneKit_SwiftUI

struct CaptureView : UIViewRepresentable
{
    @Environment(RoomCaptureController.self) private var captureController

    func makeUIView(context: Context) -> some UIView {
        captureController.roomCaptureView
    }
  
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct ActivityView: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil
  
  
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        return controller
    }
  
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

struct ScanningView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(RoomCaptureController.self) private var captureController
    @State private var current_coords: simd_float4x4 = simd_float4x4()
    @State private var current_angle: [Float] = []
    @State private var showingDeviceManager: Bool = false
    @State private var newDevice = Device()
    @State private var editMode = false
    
    var body: some View {
        @Bindable var bindableController = captureController
    
        ZStack(alignment: .bottom) {
            CaptureView()
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button("Cancel") {
                    captureController.stopSession()
                    captureController.clearDevices()
                    captureController.clearResults()
                    presentationMode.wrappedValue.dismiss()
                })
                .navigationBarItems(trailing: Button("Done") {
                    captureController.stopSession()
                    captureController.showExportButton = true
                }.opacity(captureController.showExportButton ? 0 : 1)).onAppear() {
                    captureController.showExportButton = false
                    captureController.startSession()
                }
            HStack{
                if captureController.finalResult != nil {
                    NavigationLink(destination: ModelView(devices: captureController.deviceLocations, wallTransforms: captureController.wallTransforms), label: {Text("Show 3D Model")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                        .opacity((captureController.finalResult != nil) ? 1 : 0)
                        .padding(.leading)
                }
                Spacer()
                Button(action: {
                    showingDeviceManager.toggle()
                }, label: {
                    Text("Add Device").font(.title2)
                })  .buttonStyle(.borderedProminent)
                    .cornerRadius(40)
                    .opacity(captureController.showExportButton ? 0 : 1)
                    .padding()
                    .sheet(isPresented: $showingDeviceManager, content:{
                        DeviceView(device: $newDevice, onScreen: $showingDeviceManager, edit: $editMode)
                    })
                Spacer()
                Button(action: {
                    current_coords = captureController.getTransform()
                    current_angle = captureController.getAngles()
                }, label: {
                    Text("Show Transform: \(current_angle)").font(.title2)
                }).buttonStyle(.borderedProminent)
                    .cornerRadius(40)
                    .padding()
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "camera.metering.matrix")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Roomscanner").font(.title)
                Spacer().frame(height: 40)
                Text("Scan the room by pointing the camera at all surfaces. Model export supports usdz format.")
                Spacer().frame(height: 40)
                NavigationLink(destination: ScanningView(), label: {Text("Start Scan")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
  }
}
