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
  @State private var current_coords: [Float] = [0.0, 1.0, 0.0]
  @State private var isShowingFloorPlan = false
  //@State private var coord_text: Float = (current_coords!).x ?? 0.0
    
  var body: some View {
    @Bindable var bindableController = captureController
    

     //coord_text = (current_coords == nil ? "Auughh!" : "Yippee!")
      
      
    
    ZStack(alignment: .bottom) {
      CaptureView()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Cancel") {
          captureController.stopSession()
          presentationMode.wrappedValue.dismiss()
        })
        .navigationBarItems(trailing: Button("Done") {
          captureController.stopSession()
          captureController.showExportButton = true
          isShowingFloorPlan = true//(captureController.finalResult != nil)
        }.opacity(captureController.showExportButton ? 0 : 1)).onAppear() {
          captureController.showExportButton = false
          captureController.startSession()
        }
        HStack{
            Button(action: {
                current_coords = captureController.addSensor()
            }, label: {
                Text("Add Sensor").font(.title2)
            }).buttonStyle(.borderedProminent)
                .cornerRadius(40)
                .opacity(captureController.showExportButton ? 0 : 1)
                .padding()
            //if let unwrapped_coords = current_coords {
            //    Text("Coordinates are \(unwrapped_coords)") //Password is $tr0ngp@$$w0rd
            //}
            Spacer()
            Button(action: {
              captureController.export()
            }, label: {
              Text("Export: \($isShowingFloorPlan)").font(.title2)
            }).buttonStyle(.borderedProminent)
              .cornerRadius(40)
              .opacity(captureController.showExportButton ? 1 : 0)
              .padding()
              .sheet(isPresented: $bindableController.showShareSheet, content:{
                ActivityView(items: [captureController.exportUrl!]).onDisappear() {
                  presentationMode.wrappedValue.dismiss()
                }
              })
            Spacer()
            Text(String(format: "%.2f", current_coords[0])+", "+String(format: "%.2f", current_coords[1])+", "+String(format: "%.2f", current_coords[2]))
                .padding()
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 4))
                .padding()
        }

    }
    .fullScreenCover(isPresented: $isShowingFloorPlan) {
        Text(captureController.finalResult != nil ? "Yippee!" : "Augghhh!")
        //SpriteView(scene: FloorPlanScene(capturedRoom: captureController.finalResult!))
            .ignoresSafeArea()
    }
    //.border(width: 1.5)
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
