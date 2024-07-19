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
    //private var arSession: ARSession
    //private var arConfig: ARWorldTrackingConfiguration
    var sessionConfig: RoomCaptureSession.Configuration
    var finalResult: CapturedRoom?
    var deviceID: Int = 0
    var wallTransforms: [simd_float4x4] = []
    
    var deviceLocations: [Device] = []
  
    init() {
        //let arConfig = ARWorldTrackingConfiguration()
        //arConfig.worldAlignment = .gravityAndHeading
        //arSession = ARSession()
        //arSession.configuration = arConfig
        //arSession.run(arConfig)
        roomCaptureView = RoomCaptureView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))//, arSession: arSession)
        sessionConfig = RoomCaptureSession.Configuration()
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
    }
  
    func startSession() {
        roomCaptureView.captureSession.run(configuration: sessionConfig)
    }
  
    func stopSession() {
        roomCaptureView.captureSession.stop()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //roomCaptureView.captureSession.arSession.currentFrame
        let transform = frame.camera.transform
        let position = transform.columns.3
        print(position.x, position.y, position.z)     // UPDATING
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
        let maxHeight = self.highestPoint()
        for device in self.deviceLocations {
            if device.getOnCeiling() {
                var oldLocation = device.getLocation()
                device.setLocation(location: simd_make_float3(oldLocation.x, maxHeight, oldLocation.z))
            }
        }
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
    
    func generateCSV() -> URL {
        var fileURL: URL!
        // heading of CSV file.
        let heading = "Tag, X (m), Y (m), Z (m), Device Category, Air Flow Direction, On Ceiling, Width (cm), Height/Depth (cm), Air Conditioner Type, Air Supply Type\n"
        
        // file rows
        let rows = deviceLocations.map { "\($0.getTag()),\($0.getLocation().x),\($0.getLocation().y),\($0.getLocation().z),\($0.getType()),\($0.getDirection()),\($0.getOnCeiling()),\($0.getWidth()),\($0.getHeight()),\($0.getConditionerType()),\($0.getSupplierType())" }
        
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
    
    func addDevice(device: Device){
        //var device = Device(location: position, tag: deviceID)
        if device.getTag() == -1{
            device.setTag(tag: deviceID)
            deviceID = deviceID + 1
        }
        deviceLocations.append(device)
        //let deviceAnchor = AnchorEntity(world: position)
    }
    
    func clearDevices() {
        deviceLocations = []
    }
    
    func clearResults() {
        finalResult = nil
    }
    
    func highestPoint() -> Float{
        let walls = finalResult?.walls ?? []
        var maxHeight: Float = 0
        for wall in walls {
            if wall.dimensions.y > maxHeight{
                maxHeight = wall.dimensions.y
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
