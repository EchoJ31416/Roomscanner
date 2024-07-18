import SwiftUI
import Swift
import RoomPlan
import SceneKit
import SceneKit.ModelIO



struct ModelView: View {
    @Environment(RoomCaptureController.self) private var captureController
    var devices: [Device] = []
    var wallTransforms: [simd_float4x4] = []
    var scene = makeScene()
    var importURL = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
    var exportURL = FileManager.default.temporaryDirectory.appending(path: "room.usdz")
    @State var showShareSheet = false
    @ObservedObject var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    
    init(devices: [Device], wallTransforms: [simd_float4x4]){
        let mdlAsset = MDLAsset(url: importURL)
        let asset = mdlAsset.object(at: 0) // extract first object
        let assetNode = SCNNode(mdlObject: asset)
        scene?.rootNode.addChildNode(assetNode)
        
        self.wallTransforms = wallTransforms
        var wallNode: SCNNode
        var wallGeometry = SCNPyramid(width: 0.125, height: 0.3, length: 0.0625)
        wallGeometry.firstMaterial?.diffuse.contents = UIColor.red
        for wall in wallTransforms{
            wallNode = SCNNode(geometry: wallGeometry)
            wallNode.simdTransform = rotateX(initial: wall, degrees: Float(Double.pi)/2)
            wallNode.castsShadow = true
            scene?.rootNode.addChildNode(wallNode)
        }
        
        self.devices = devices
        for device in self.devices{
            scene?.rootNode.addChildNode(addDevice(device: device))
        }
//        viewModel.deviceList = self.devices
//        var geometry = SCNGeometry()
//        geometry = SCNSphere(radius: 0.04)
//        geometry.firstMaterial?.diffuse.contents = UIColor.black
//        for device in self.devices{
//            node = SCNNode()
//            if ((device.getRawType() != Device.category.Sensor) && (device.getRawType() != Device.category.Heater)){
//                geometry = SCNPlane(width: CGFloat(device.getLength()/100), height: CGFloat(device.getWidth()/100))
//                geometry.firstMaterial?.isDoubleSided = true
//                geometry.firstMaterial?.diffuse.contents = UIColor.darkGray
//                var directional = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.02, height: 0.5))
//                directional.simdEulerAngles = device.getRotation()
//                node.addChildNode(directional)
//            }
//            node.geometry = geometry
//            //node = SCNNode(geometry: geometry)
//            node.castsShadow = true
//            node.simdPosition = device.getLocation()
//            node.name = "Device: \(device.getTag())"
//            scene?.rootNode.addChildNode(node)
//        }
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
                    Text("\(acos(wallTransforms[0].columns.0[0]))")
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
    
    func rotateX(initial: simd_float4x4, degrees: Float) -> simd_float4x4 {
        var initColumns: [simd_float3] = []
        initColumns.append(simd_make_float3(initial.columns.0))
        initColumns.append(simd_make_float3(initial.columns.1))
        initColumns.append(simd_make_float3(initial.columns.2))
        var smallMatrix = simd_float3x3(initColumns)
        var rotateMatrix = simd_float3x3(simd_make_float3(1, 0, 0), simd_make_float3(0, cos(degrees), -sin(degrees)), simd_make_float3(0, sin(degrees), cos(degrees)))
        //var inverseMatrix = smallMatrix.inverse
        var normalMatrix = smallMatrix*rotateMatrix//inverseMatrix.transpose
        var newColumns: [simd_float4] = []
        newColumns.append(simd_make_float4(normalMatrix.columns.0))
        newColumns.append(simd_make_float4(normalMatrix.columns.1))
        newColumns.append(simd_make_float4(normalMatrix.columns.2))
        newColumns.append(initial.columns.3)
        return simd_float4x4(newColumns)
    }
    
    func setToFlat(initial: simd_float4x4) -> simd_float4x4{
        var flatMatrix = simd_float3x3(simd_make_float3(1, 0, 0), simd_make_float3(0, 0, -1), simd_make_float3(0, 1, 0))
        var newColumns: [simd_float4] = []
        newColumns.append(simd_make_float4(flatMatrix.columns.0))
        newColumns.append(simd_make_float4(flatMatrix.columns.1))
        newColumns.append(simd_make_float4(flatMatrix.columns.2))
        newColumns.append(initial.columns.3)
        return simd_float4x4(newColumns)
    }
    
    func rotateY(initial: simd_float4x4, degrees: Float) -> simd_float4x4 {
        var degrees = degrees/180 * Float.pi
        var initColumns: [simd_float3] = []
        initColumns.append(simd_make_float3(initial.columns.0))
        initColumns.append(simd_make_float3(initial.columns.1))
        initColumns.append(simd_make_float3(initial.columns.2))
        var smallMatrix = simd_float3x3(initColumns)
        var rotateMatrix = simd_float3x3(simd_make_float3(cos(degrees), 0, sin(degrees)), simd_make_float3(0, 1, 0), simd_make_float3(-sin(degrees), 0, cos(degrees)))
        //var inverseMatrix = smallMatrix.inverse
        var normalMatrix = smallMatrix*rotateMatrix//inverseMatrix.transpose
        var newColumns: [simd_float4] = []
        newColumns.append(simd_make_float4(normalMatrix.columns.0))
        newColumns.append(simd_make_float4(normalMatrix.columns.1))
        newColumns.append(simd_make_float4(normalMatrix.columns.2))
        newColumns.append(initial.columns.3)
        return simd_float4x4(newColumns)
    }
    
    func addDevice(device: Device) -> SCNNode {
        var node: SCNNode = SCNNode()
        node.castsShadow = true
        node.simdPosition = device.getLocation()
        node.name = "Device: \(device.getTag())"
        var geometry = SCNGeometry()
        geometry = SCNSphere(radius: 0.04)
        if ((device.getRawType() != Device.category.Sensor) && (device.getRawType() != Device.category.Heater)){
            geometry = SCNPlane(width: CGFloat(device.getLength()/100), height: CGFloat(device.getWidth()/100))
            geometry.firstMaterial?.isDoubleSided = true
            switch device.getRawDirection() {
            case .Up:
                node.simdTransform = setToFlat(initial: node.simdTransform)
            case .Down:
                node.simdTransform = setToFlat(initial: node.simdTransform)
            case .Left:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: 0)
            case .Right:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: 0)
            case .Towards:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: 0)
            case .Away:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: 0)
            case .NA:
                node.simdTransform = node.simdTransform
            }
            //var directional = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.02, height: 0.5))
            //directional.simdEulerAngles = device.getRotation()
            //node.addChildNode(directional)
        }
        var color: UIColor
        switch device.getRawType() {
        case .Sensor: color = UIColor.black
        case .AirConditioning: color = UIColor.blue
        case .Heater: color = UIColor.green
        case .Fan: color = UIColor.cyan
        case .AirSupply: color = UIColor.red
        case .AirReturn: color = UIColor.brown
        case .AirExchange: color = UIColor.lightGray
        case .DoorOpen: color = UIColor.orange
        case .WindowOpen: color = UIColor.yellow
        }
        geometry.firstMaterial?.diffuse.contents = color
        node.geometry = geometry
        //node = SCNNode(geometry: geometry)
        return node
    }
}

//struct ModelView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelView(devices: [Device(location: simd_float3(0.0, 1.0, 0.0))])
//    }
//}
