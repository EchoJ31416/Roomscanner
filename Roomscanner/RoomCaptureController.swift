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
    var sensorID: Int = 0
    
    var sensorLocations: [Sensor] = []
  
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
        //showShareSheet = true
    }
    
    func exportLink() -> URL{
        exportUrl = FileManager.default.temporaryDirectory.appending(path: "scan.usdz")
        do {
          try finalResult?.export(to: exportUrl!)
        } catch {
          print("Error exporting usdz scan.")
        }
        return exportUrl!
    }
    
    func exportImage() {
      exportUrl = FileManager.default.temporaryDirectory.appending(path: "plan.png")
      do {
        try finalResult?.export(to: exportUrl!)
      } catch {
        print("Error exporting floorplan png.")
        return
      }
      showShareSheet = true
    }
    

    func addSensor() -> [Float] {
        //showExportButton = true
        let currentFrame = roomCaptureView.captureSession.arSession.currentFrame
        let transform = currentFrame!.camera.transform
        let position = simd_make_float3(transform.columns.3)
        var sensor = Sensor(location: position, tag: sensorID)
        sensorID = sensorID + 1
        sensorLocations.append(sensor)
        let sensorAnchor = AnchorEntity(world: position)
        return [position.x, position.y, position.z]
        //print(position.x, position.y, position.z)
    }
  
    required init?(coder: NSCoder) {
        fatalError("Not needed.")
    }
  
    func encode(with coder: NSCoder) {
        fatalError("Not needed.")
    }
}
