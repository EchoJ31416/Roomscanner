import SwiftUI
import SceneKit
import SceneKit.ModelIO



struct ModelView: View {
    @Environment(RoomCaptureController.self) private var captureController
    var sensors: [Sensor] = []
    var scene = makeScene()
    var importURL = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
    var exportURL = FileManager.default.temporaryDirectory.appending(path: "room.usdz")
    @State var showShareSheet = false
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    
    init(sensors: [Sensor]){
        let mdlAsset = MDLAsset(url: importURL)
        let asset = mdlAsset.object(at: 0) // extract first object
        let assetNode = SCNNode(mdlObject: asset)
        scene?.rootNode.addChildNode(assetNode)
        var node: SCNNode
        self.sensors = sensors
        viewModel.sensorList = self.sensors
        for sensor in self.sensors{
            node = SCNNode(geometry: SCNSphere(radius: 0.04))
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            node.castsShadow = true
            node.simdPosition = sensor.getLocation()
            node.name = "Sensor: \(sensor.getTag())"
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
                pointOfView: setUpCamera(sensor: viewModel.selectedSensor),
                options: viewModel.selectedSensor == nil ? [.allowsCameraControl] : []
            )
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(trailing: Button("Done") {
                captureController.clearSensors()
                captureController.clearResults()
                captureController.stopSession()
                presentationMode.wrappedValue.dismiss()
            }.opacity(1))
            VStack {
                HStack{
                    if let sensor = viewModel.selectedSensor {
                        Text("\(sensor.getTag())")
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(14)
                            .padding(12)
                    }
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
                }

                Spacer()

                HStack {
                    HStack {
                        Button(action: viewModel.selectPreviousSensor) {
                            Image(systemName: "arrow.backward.circle.fill")
                        }
                        Button(action: viewModel.selectNextSensor) {
                            Image(systemName: "arrow.forward.circle.fill")
                        }
                    }
                    Spacer()
                    Text("\(String(describing: sensorNode(sensor: viewModel.selectedSensor ?? Sensor(location: simd_float3(-100.0, -100.0, -100.0), tag: -1))))")
                    Text("\(String(describing: viewModel.selectedSensor?.getLocation()))")
                    Spacer()
                    Text(viewModel.title).foregroundColor(.white)
                    Spacer()

                    if viewModel.selectedSensor != nil {
                        Button(action: viewModel.clearSelection) {
                            Image(systemName: "xmark.circle.fill")
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
  
    func setUpCamera(sensor: Sensor?) -> SCNNode? {
        let cameraNode = scene?.rootNode
            .childNode(withName: "camera", recursively: false)
    
        if let sensorNode = sensor.flatMap(sensorNode(sensor:)) {
            let constraint = SCNLookAtConstraint(target: sensorNode)
            cameraNode?.constraints = [constraint]
            let globalPosition = sensorNode
                .convertPosition(SCNVector3(x: 5, y: 1, z: 0), to: nil)
            let move = SCNAction.move(to: globalPosition, duration: 1.0)
            cameraNode?.runAction(move)
        }
        return cameraNode
    }
  
    func sensorNode(sensor: Sensor) -> SCNNode? {
        scene?.rootNode.childNode(withName: "Sensor: \(sensor.getTag())", recursively: false)
    }
    
    func export() {
        scene?.write(to: self.exportURL, delegate: nil)
        
        showShareSheet = true
    }
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView(sensors: [Sensor(location: simd_float3(0.0, 1.0, 0.0))])
    }
}
