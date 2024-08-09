import SwiftUI
import Swift
import RoomPlan
import SceneKit
import SceneKit.ModelIO



struct ModelView: View {
    @Environment(RoomCaptureController.self) private var captureController
    @State private var showingDeviceManager = false
    @State private var editDevice = Device.emptyDevice
    @State private var selectedDevice: Device? = nil
    @State var Index = 0
    @Binding var devices: [Device]
    var wallTransforms: [simd_float4x4] = []
    var floorTransforms: [simd_float4x4] = []
    @State private var cameraAngle = simd_float3()
    var scene = makeScene()
    var importURL = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
    var exportURL = FileManager.default.temporaryDirectory.appending(path: "room.usdz")
    @State var showShareSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    
    init(devices: Binding<[Device]>, wallTransforms: [simd_float4x4], highPoint: Float, floorTransforms: [simd_float4x4]){
        let mdlAsset = MDLAsset(url: importURL)
        let asset = mdlAsset.object(at: 0) // extract first object
        let assetNode = SCNNode(mdlObject: asset)
        assetNode.name = "background"
        scene?.rootNode.addChildNode(assetNode)
        
        self.wallTransforms = wallTransforms
        self.floorTransforms = floorTransforms
        
//        if wallTransforms.count != 0 {
//            var wallNode: SCNNode
//            var wallGeometry = SCNPyramid(width: 0.125, height: 0.3, length: 0.0625)
//            wallGeometry.firstMaterial?.diffuse.contents = UIColor.black
//            wallNode = SCNNode(geometry: wallGeometry)
//            wallNode.simdTransform = rotateX(initial: wallTransforms[0], degrees: Float(Double.pi)/2)
//            wallNode.castsShadow = true
//            scene?.rootNode.addChildNode(wallNode)
//        }
        
        self._devices = devices

        for var device in self.devices{
            if device.onCeiling {
                let oldLocation = device.getLocation()
                device.setLocation(location: simd_make_float3(oldLocation.x, highPoint, oldLocation.z))
            }
            scene?.rootNode.addChildNode(addDevice(device: device))
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
                pointOfView: setUpCamera(device: selectedDevice),
                options: selectedDevice == nil ? [.allowsCameraControl] : []
            )
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(trailing: Button("Done") {
                devices = []
                captureController.clearResults()
                //captureController.stopSession()
                presentationMode.wrappedValue.dismiss()
            })
            VStack {
                HStack{
                    Button(action: {
                        self.export()
                    }, label: {
                        Text("Export").font(.title2)
                    }).buttonStyle(.borderedProminent)
                        .cornerRadius(40)
                        .padding()
                        .sheet(isPresented: $showShareSheet, content:{
                            ActivityView(items: [self.exportURL]).onDisappear() {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                    Spacer()
                    
                    if selectedDevice != nil{
                        Button(action: {
                            var location = selectedDevice!.getLocation()
                            location.y += 0.1
                            selectedDevice?.setLocation(location: location)
                            devices[Index] = selectedDevice!
                        }, label: {
                            Text("Move up").font(.title2)
                        }).buttonStyle(.borderedProminent)
                            .cornerRadius(40)
                            .padding()
                    }
                    
                    Spacer()
                    //                    Button(action:{
                    //                        cameraAngle = self.getCameraAngle()
                    //                    }, label: {
                    //                        Text("\(cameraAngle)")
                    //                    }).buttonStyle(.borderedProminent)
                    //                        .cornerRadius(40)
                    //                        .padding()
                    //                    Spacer()
                    ShareLink(item:generateCSV()) {
                        Label("Export CSV", systemImage: "list.bullet.rectangle.portrait")
                    }
                    .buttonStyle(.borderedProminent)
                    .cornerRadius(40)
                    .padding()
                    
                }
                
                
                    
                Spacer()
                if selectedDevice != nil{
                    Button(action: {
                        var location = selectedDevice!.getLocation()
                        location.y -= 0.1
                        selectedDevice?.setLocation(location: location)
                        devices[Index] = selectedDevice!
                    }, label: {
                        Text("Move down").font(.title2)
                    }).buttonStyle(.borderedProminent)
                        .cornerRadius(40)
                        .padding()
                }
                
                HStack {
                    Button(action: {
                        self.switchProjection()
                    }, label: {
                        Text("Switch Style").font(.title2)
                    }).buttonStyle(.borderedProminent)
                        .cornerRadius(40)
                        .padding()
                    if devices.count != 0{
                        HStack {
                            Button(action: {
                                selectPreviousDevice()
                            }) {
                                Image(systemName: "arrow.backward.circle.fill")
                            }
                            Button(action: {
                                selectNextDevice()
                            }) {
                                Image(systemName: "arrow.forward.circle.fill")
                            }
                        }
                    }
                    if selectedDevice != nil {
                        @State var device = selectedDevice!
                        Spacer()
                        Text("Device Tag: \(device.tag)")
                        Spacer()
                        Text("\(device.getAngle()), \(getWallYAngle()), \(device.getAngle() - getWallYAngle())")
                        Spacer()
                        Text("Type: \(device.type.stringValue)")
                        Spacer()
                        Button(action: {
                            showingDeviceManager = true
                            editDevice = selectedDevice!
                        }, label: {
                            Text("Edit Device").font(.title2)
                        })  .buttonStyle(.borderedProminent)
                            .cornerRadius(40)
                            .padding()
                            .sheet(isPresented: $showingDeviceManager, content:{
                                NavigationStack {
                                    DeviceView(device: $editDevice)
                                        .toolbar {
                                            ToolbarItem(placement: .cancellationAction) {
                                                Button("Cancel") {
                                                    showingDeviceManager = false
                                                }
                                            }
                                            ToolbarItem(placement: .confirmationAction) {
                                                Button("Done") {
                                                    showingDeviceManager = false
                                                    selectedDevice = editDevice
                                                    devices[Index] = editDevice
                                                }
                                            }
                                        }
                                }
                            })
                        Button(action: clearSelection) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    } else {
                        Text("No device selected")
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
        cameraNode?.camera?.usesOrthographicProjection = true
    
        if let deviceNode = device.flatMap(deviceNode(device:)) {
            let constraint = SCNLookAtConstraint(target: deviceNode)
            cameraNode?.constraints = [constraint]
            let globalPosition = deviceNode
                .convertPosition(SCNVector3(x: 1, y: 0, z: 0), to: nil)
            let move = SCNAction.move(to: globalPosition, duration: 1.0)
            cameraNode?.runAction(move)
            //cameraNode?.constraints=[]
        } else {
            //var backgroundNode = scene?.rootNode.childNode(withName: "background", recursively: false)
            //backgroundNode.p
            var settingPosition = self.floorTransforms[0].columns.3//backgroundNode!.worldPosition//SCNVector3(x:0, y:5, z:0)
            settingPosition.x += 0
            settingPosition.y += 7
            settingPosition.z += 0
            cameraNode?.simdPosition = simd_make_float3(settingPosition)
        }
        return cameraNode
    }
    
//    func getCameraAngle() -> simd_float3{
//        var cameraNode = scene?.rootNode
//            .childNode(withName: "camera", recursively: false)
//        return scene?.rootNode.camera
//    }
    
    func switchProjection() {
        let cameraNode = scene?.rootNode
            .childNode(withName: "camera", recursively: false)
        cameraNode?.camera?.usesOrthographicProjection.toggle()
        
    }
  
    func deviceNode(device: Device) -> SCNNode? {
        scene?.rootNode.childNode(withName: "Device: \(device.id)", recursively: false)
    }
    
    func export() {
        scene?.write(to: self.exportURL, delegate: nil)
        
        showShareSheet = true
    }
    
    func addDevice(device: Device) -> SCNNode {
        var color: UIColor
        switch device.type {
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
        var node: SCNNode = SCNNode()
        node.castsShadow = true
        node.simdPosition = device.getLocation()
        node.name = "Device: \(device.id)"
        var geometry = SCNGeometry()
        geometry = SCNSphere(radius: 0.04)
        if ((device.type != Category.Sensor) && (device.type != Category.Heater)){
            geometry = SCNPlane(width: CGFloat(device.width/100), height: CGFloat(device.height/100))
            geometry.firstMaterial?.isDoubleSided = true
            node.simdTransform = parallel(inWall: node.simdTransform, paraWall: self.wallTransforms[0])
            var angleDiff = device.getAngle() - getWallYAngle()
            switch device.direction{
            case .Up:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: 90)
            case .Down:
                node.simdTransform = rotateX(initial: node.simdTransform, degrees: -90)
            case .Left:
                if ((abs(angleDiff) <= 45) || (abs(angleDiff) >= 315)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 90)
                } else if ((abs(angleDiff) > 45) && (abs(angleDiff) <= 135)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 0)
                } else if ((abs(angleDiff) > 135) && (abs(angleDiff) <= 225)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: -90)
                } else {
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 180)
                }
            case .Right:
                if ((abs(angleDiff) <= 45) || (abs(angleDiff) >= 315)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: -90)
                } else if ((abs(angleDiff) > 45) && (abs(angleDiff) <= 135)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 180)
                } else if ((abs(angleDiff) > 135) && (abs(angleDiff) <= 225)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 90)
                } else {
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 0)
                }
            case .Towards:
                if ((abs(angleDiff) <= 45) || (abs(angleDiff) >= 315)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 0)
                } else if ((abs(angleDiff) > 45) && (abs(angleDiff) <= 135)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 90)
                } else if ((abs(angleDiff) > 135) && (abs(angleDiff) <= 225)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 180)
                } else {
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: -90)
                }
            case .Away:
                if ((abs(angleDiff) <= 45) || (abs(angleDiff) >= 315)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 180)
                } else if ((abs(angleDiff) > 45) && (abs(angleDiff) <= 135)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: -90)
                } else if ((abs(angleDiff) > 135) && (abs(angleDiff) <= 225)){
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 0)
                } else {
                    node.simdTransform = rotateY(initial: node.simdTransform, degrees: 90)
                }
            case .NA:
                node.simdTransform = node.simdTransform
            }
            var directional = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.02, height: 0.5))
            directional.geometry?.firstMaterial?.diffuse.contents = color
            directional.simdPivot.columns.3[1] = directional.simdPivot.columns.3[1] - 0.25
            directional.simdTransform = rotateX(initial: directional.simdTransform, degrees: -90)
            directional.simdTransform.columns
            node.addChildNode(directional)
        }
        
        geometry.firstMaterial?.diffuse.contents = color
        //geometry.firstMaterial?.specular.contents = UIColor.black
        node.geometry = geometry
        return node
    }
    
    func getWallYAngle() -> Float {
        let ySinAngle = 180*asin(-wallTransforms[0].columns.2[0])/Float.pi
        let xAngle = atan2(wallTransforms[0].columns.2[1], wallTransforms[0].columns.2[2])
        let yCosAngle = 180*acos(wallTransforms[0].columns.2[2]/abs(cos(xAngle)))/Float.pi
        var yFinalAngle: Float = 0.0
        if (yCosAngle >= 90) {
            if (ySinAngle >= 0) {
                yFinalAngle = yCosAngle
            } else {
                yFinalAngle = 360-yCosAngle
            }
        } else {
            if (ySinAngle >= 0) {
                yFinalAngle = ySinAngle
            } else {
                yFinalAngle = 360+ySinAngle
            }
        }
        return yFinalAngle
    }
    
    func selectNextDevice() {
        changeSelection(offset: 1)
    }

    func selectPreviousDevice() {
        changeSelection(offset: -1)
    }

    func clearSelection() {
        selectedDevice = nil
    }

    private func changeSelection(offset: Int) {
        let newIndex = Index + offset

        if newIndex < 0 {
            Index = devices.endIndex-1
        } else if newIndex < devices.endIndex {
            Index = newIndex
        } else {
            Index = 0
        }
        self.selectedDevice = devices[Index]
    }
    
    func generateCSV() -> URL {
        var fileURL: URL!
        // heading of CSV file.
        let heading = "Tag, X (m), Y (m), Z (m), Device Category, Air Flow Direction, On Ceiling, Width (cm), Height/Depth (cm), Air Source, Air Conditioner Type, Air Supply Type, Window Type, Door Type, How Open\n"
        
        // file rows
        let rows = devices.map { "\($0.tag),\($0.getLocation().x),\($0.getLocation().y),\($0.getLocation().z),\($0.type.stringValue),\($0.direction.stringValue),\($0.onCeiling),\($0.width),\($0.height),\($0.airSource),\($0.conditioner.stringValue),\($0.supplier.stringValue),\($0.window.stringValue),\($0.door.stringValue),\($0.open.stringValue)" }
        
        // rows to string data
        let stringData = heading + rows.joined(separator: "\n")
        
        do {
            
            let path = try FileManager.default.url(for: .documentDirectory,
                                                   in: .allDomainsMask,
                                                   appropriateFor: nil,
                                                   create: false)
            
            fileURL = path.appendingPathComponent("Devices.csv")
            
            // append string data to file
            try stringData.write(to: fileURL, atomically: true , encoding: .utf8)
            print(fileURL!)
            
        } catch {
            print("error generating csv file")
        }
        return fileURL
    }
}
