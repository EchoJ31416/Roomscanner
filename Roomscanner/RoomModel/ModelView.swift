import SwiftUI
import SceneKit
import SceneKit.ModelIO



struct ModelView: View {
    @Environment(RoomCaptureController.self) private var captureController
    var devices: [Device] = []
    var scene = makeScene()
    var importURL = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
    var exportURL = FileManager.default.temporaryDirectory.appending(path: "room.usdz")
    @State var showShareSheet = false
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    
    init(devices: [Device]){
        let mdlAsset = MDLAsset(url: importURL)
        let asset = mdlAsset.object(at: 0) // extract first object
        let assetNode = SCNNode(mdlObject: asset)
        scene?.rootNode.addChildNode(assetNode)
        var node: SCNNode
        self.devices = devices
        viewModel.deviceList = self.devices
        let geometry = SCNSphere(radius: 0.04)
        geometry.firstMaterial?.diffuse.contents = UIColor.black
        for device in self.devices{
            node = SCNNode(geometry: geometry)
            node.castsShadow = true
            node.simdPosition = device.getLocation()
            node.name = "Device: \(device.getTag())"
            scene?.rootNode.addChildNode(node)
        }
    }
  
    static func makeScene() -> SCNScene? {
        let scene = SCNScene(named: "RoomPlan Scene.scn")
        return scene
    }
    
    var body: some View {
        @Bindable var bindableController = captureController
        
        ZStack {
            SceneView(
                scene: scene,
                pointOfView: setUpCamera(device: viewModel.selectedDevice),
                options: viewModel.selectedDevice == nil ? [.allowsCameraControl] : []
            )
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(trailing: Button("Done") {
                captureController.clearDevices()
                captureController.clearResults()
                captureController.stopSession()
                presentationMode.wrappedValue.dismiss()
            }.opacity(1))
            VStack {
                HStack{
                    Button(action: {
                        self.export()
                    }, label: {
                        Text("Export").font(.title2)
                    }).buttonStyle(.borderedProminent)
                        .cornerRadius(40)
                        .opacity(1)
                        .padding()
                        .sheet(isPresented: $showShareSheet, content:{
                            ActivityView(items: [self.exportURL]).onDisappear() {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                    Spacer()
                    ShareLink(item:captureController.generateCSV()) {
                        Label("Export CSV", systemImage: "list.bullet.rectangle.portrait")
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(40)
                    .padding()
                    
                }
                    
                Spacer()
                
                HStack {
                    HStack {
                        Button(action: viewModel.selectPreviousDevice) {
                            Image(systemName: "arrow.backward.circle.fill")
                        }
                        Button(action: viewModel.selectNextDevice) {
                            Image(systemName: "arrow.forward.circle.fill")
                        }
                    }
                    if let device = viewModel.selectedDevice {
                        Spacer()
                        Text("Device Tag: \(device.getTag())")
                        Spacer()
                        let location = device.getLocation()
                        Text("Location: [\(String(format: "%.2f", location.x)), \(String(format: "%.2f", location.y)), \(String(format: "%.2f", location.z))]")
                        Spacer()
                        Text("Type: \(device.getType())")
                        Spacer()
                        
                        if viewModel.selectedDevice != nil {
                            Button(action: viewModel.clearSelection) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                    }
                }
                    .padding(8)
                    .background(Color.green)
                    .cornerRadius(14)
                    .padding(12)
            }
        }
    }
  
    func setUpCamera(device: Device?) -> SCNNode? {
        let cameraNode = scene?.rootNode
            .childNode(withName: "camera", recursively: false)
    
        if let deviceNode = device.flatMap(deviceNode(device:)) {
            let constraint = SCNLookAtConstraint(target: deviceNode)
            cameraNode?.constraints = [constraint]
            let globalPosition = deviceNode
                .convertPosition(SCNVector3(x: 5, y: 1, z: 0), to: nil)
            let move = SCNAction.move(to: globalPosition, duration: 1.0)
            cameraNode?.runAction(move)
        }
        return cameraNode
    }
  
    func deviceNode(device: Device) -> SCNNode? {
        scene?.rootNode.childNode(withName: "Device: \(device.getTag())", recursively: false)
    }
    
    func export() {
        scene?.write(to: self.exportURL, delegate: nil)
        
        showShareSheet = true
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView(devices: [Device(location: simd_float3(0.0, 1.0, 0.0))])
    }
}
