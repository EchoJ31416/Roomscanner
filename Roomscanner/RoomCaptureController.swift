//
//  RoomCaptureController.swift
//  Roomscanner
//
//  Created by Mikael Deurell on 2022-07-14.
//

import Foundation
import RoomPlan
import Observation
import ARKit
import RealityKit

@Observable 
class RoomCaptureController: RoomCaptureViewDelegate, RoomCaptureSessionDelegate, ObservableObject
{
    var roomCaptureView: RoomCaptureView
    var showExportButton = false
    var showShareSheet = false
    var exportUrl: URL?
    var sessionConfig: RoomCaptureSession.Configuration
    var finalResult: CapturedRoom?
    var deviceID: Int = 0
    var wallTransforms: [simd_float4x4] = []
    
    //var deviceLocations: [Device] = []
  
    init() {
        roomCaptureView = RoomCaptureView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        sessionConfig = RoomCaptureSession.Configuration()
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.worldAlignment = .gravityAndHeading
        roomCaptureView.captureSession.arSession.run(arConfig)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
    }
  
    func startSession() {
        roomCaptureView.captureSession.run(configuration: sessionConfig)
    }
  
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
  
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
  
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResult = processedResult
        var walls = finalResult!.walls
        for wall in walls{
            self.wallTransforms.append(wall.transform)
        }
//        let maxHeight = self.highestPoint()
//        for var device in self.deviceLocations {
//            if device.onCeiling {
//                var oldLocation = device.getLocation()
//                device.setLocation(location: simd_make_float3(oldLocation.x, maxHeight, oldLocation.z))
//            }
//        }
        self.export()
    }
  
    func export() {
        exportUrl = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
        do {
            try finalResult?.export(to: exportUrl!)
        } catch {
            print("Error exporting usdz scan.")
            return
        }
    }
    
//    func generateCSV() -> URL {
//        var fileURL: URL!
//        // heading of CSV file.
//        let heading = "Tag, X (m), Y (m), Z (m), Device Category, Air Flow Direction, On Ceiling, Width (cm), Height/Depth (cm), Air Source, Air Conditioner Type, Air Supply Type, Window Type, Door Type, How Open\n"
//        
//        // file rows
//        let rows = deviceLocations.map { "\($0.tag),\($0.getLocation().x),\($0.getLocation().y),\($0.getLocation().z),\($0.type.stringValue),\($0.direction.stringValue),\($0.onCeiling),\($0.width),\($0.height),\($0.airSource),\($0.conditioner.stringValue),\($0.supplier.stringValue),\($0.window.stringValue),\($0.door.stringValue),\($0.open.stringValue)" }
//        
//        // rows to string data
//        let stringData = heading + rows.joined(separator: "\n")
//        
//        do {
//            
//            let path = try FileManager.default.url(for: .documentDirectory,
//                                                   in: .allDomainsMask,
//                                                   appropriateFor: nil,
//                                                   create: false)
//            
//            fileURL = path.appendingPathComponent("Devices.csv")
//            
//            // append string data to file
//            try stringData.write(to: fileURL, atomically: true , encoding: .utf8)
//            print(fileURL!)
//            
//        } catch {
//            print("error generating csv file")
//        }
//        return fileURL
//    }
    
    func getLocation() -> simd_float3 {
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        let position = simd_make_float3(transform.columns.3)
        return position
    }
    
    func getTransform() -> simd_float4x4 {
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        return transform
    }
    
    func getYAngle() -> Float {
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        return 180*(asin(transform.columns.2[0])/Float.pi)
    }
    
    func getXAngle() -> Float {
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        return atan2(transform.columns.2[1], transform.columns.2[2])
    }
    
    func getAngles() -> [Float] {
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        var ySinAngle = 180*asin(-transform.columns.2[0])/Float.pi
        var xAngle = atan2(transform.columns.2[1], transform.columns.2[2])
        var xCos = cos(xAngle)
        var yCosAngle = 180*acos(transform.columns.2[2]/abs(cos(xAngle)))/Float.pi
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
        return [180*xAngle/Float.pi, xCos, yCosAngle, ySinAngle, yFinalAngle]
    }
    
//    func addDevice(device: Device){
//        var device = device
//        if device.tag == -1{
//            device.tag = deviceID
//            deviceID = deviceID + 1
//        }
//        deviceLocations.append(device)
//        //let deviceAnchor = AnchorEntity(world: position)
//    }
    
//    func clearDevices() {
//        deviceLocations = []
//    }
    
    func clearResults() {
        finalResult = nil
    }
    
    func highestPoint() -> Float{
        let walls = finalResult?.walls ?? []
        var maxHeight: Float = 0
        for wall in walls {
            if (wall.dimensions.y/2+wall.transform.columns.3[1]) > maxHeight{
                maxHeight = wall.dimensions.y/2+wall.transform.columns.3[1]
            }
        }
        return maxHeight
    }
  
    required init?(coder: NSCoder) {
        fatalError("Not needed.")
    }
  
    func encode(with coder: NSCoder) {
        fatalError("Not needed.")
    }
}
