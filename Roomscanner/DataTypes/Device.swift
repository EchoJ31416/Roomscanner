//
//  Device.swift
//  Roomscanner
//
//  Created by User on 5/7/2024.
//

import Foundation
import RealityKit
import RoomPlan

struct Device: Identifiable{
    let id: UUID
    var transform: simd_float4x4
    var tag: Int
    var onCeiling: Bool
    var width: Float
    var height: Float
    var airSource: String
    var type = Category.Sensor
    var direction = Directions.NA
    var conditioner = Conditioner.NA
    var supplier = Supplier.NA
    var window = Window.NA
    var door = Door.NA
    var open = Open.NA
    
    
    
    init(
        id: UUID = UUID(),
         transform: simd_float4x4 = simd_float4x4(0),
         tag: Int = 0,
         onCeiling: Bool = false,
         airSource: String = "",
         width: Float = 0,
         height: Float = 0,
         type: Category = .Sensor,
         direction: Directions = .NA,
         conditioner: Conditioner = .NA,
         supplier: Supplier = .NA,
         window: Window = .NA,
         door: Door = .NA,
         open: Open = .NA)
    {
        self.id = id
        self.transform = transform
        self.tag = tag
        self.onCeiling = onCeiling
        self.airSource = airSource
        self.width = width
        self.height = height
        self.type = type
        self.direction = direction
        self.conditioner = conditioner
        self.supplier = supplier
        self.window = window
        self.door = door
        self.open = open
    }
    
    func getLocation() -> simd_float3{
        return simd_make_float3(self.transform.columns.3)
    }
    
    mutating func setLocation(location: simd_float3){
        self.transform.columns.3 = simd_make_float4(location)
        self.transform.columns.3[3] = 1
    }
    
    func getYAngle() -> Float{
        
        return 180*(asin(self.transform.columns.2[0])/Float.pi)
    }
    
    func getAngle() -> Float{
        var ySinAngle = 180*asin(-transform.columns.2[0])/Float.pi
        var xAngle = atan2(transform.columns.2[1], transform.columns.2[2])
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
        return yFinalAngle
    }
}

extension Device{
    static var emptyDevice: Device {
        Device()
    }
}

