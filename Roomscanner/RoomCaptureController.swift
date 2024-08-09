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
    var wallTransforms: [simd_float4x4] = []
    var floorTransforms: [simd_float4x4] = []
  
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
        var floors = finalResult!.floors
        for wall in walls{
            self.wallTransforms.append(wall.transform)
        }
        for floor in floors{
            self.floorTransforms.append(floor.transform)
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
