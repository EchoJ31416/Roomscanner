//
//  Device.swift
//  Roomscanner
//
//  Created by User on 5/7/2024.
//

import Foundation
import RealityKit
import RoomPlan

class Device{
    private var transform: simd_float4x4
    private var tag: Int
    private var onCeiling: Bool
    private var width: Float
    private var height: Float
    private var airSource: String
    private var type = Category.Sensor
    private var direction = Directions.NA
    private var conditioner = Conditioner.NA
    private var supplier = Supplier.NA
    private var window = Window.NA
    private var door = Door.NA
    private var open = Open.NA
    
    init(
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
    
    func getRawType() -> Category{
        return type
    }
    
    func getType() -> String{
        return self.categoryConverter(category: self.getRawType())
    }
    
    func categoryConverter(category: Category) -> String{
        switch category {
        case .Sensor: return "Sensor"
        case .AirConditioning: return "Air Conditioner"
        case .Heater: return "Heater"
        case .Fan: return "Fan"
        case .AirSupply: return "Air Supplier"
        case .AirReturn: return "Air Return"
        case .AirExchange: return "Air Exchanger"
        case .DoorOpen: return "Door"
        case .WindowOpen: return "Window"
        default: return "Unknown Device"
        }
    }
    
    func getAirSource() -> String{
        return airSource
    }
    
    func getRawConditioner() -> Conditioner{
        return conditioner
    }
    
    func getConditionerType() -> String{
        return self.conditionerConverter(conditioner: self.getRawConditioner())
    }
    
    func conditionerConverter(conditioner: Conditioner) -> String{
        switch conditioner {
        case .window: return "Window Air Conditioner"
        case .split: return "Split Air Conditioner"
        case .NA: return "N/A"
        default: return "Unknown Air Conditioner"
        }
    }
    
    func getRawDirection() -> Directions{
        return direction
    }
    
    func getDirection() -> String{
        return self.directionConverter(direction: self.getRawDirection())
    }
    
    func directionConverter(direction: Directions) -> String{
        if (direction == .NA){
            return "N/A"
        } else {
            return direction.rawValue
        }
    }
    
    func getRawSupplier() -> Supplier{
        return supplier
    }
    
    func getSupplierType() -> String{
        return self.supplierConverter(supplier: self.getRawSupplier())
    }
    
    func supplierConverter(supplier: Supplier) -> String{
        switch supplier{
        case .sameRoom: return "Same room recirculation"
        case .sharedAir: return "Shared recirculated air"
        case .mixedAir: return "Mix of recirculated and fresh air"
        case .freshAir: return "Fresh Air"
        case .NA: return "N/A"
        default: return "Unknown Air Supplier"
        }
    }
    
    func getRawWindow() -> Window{
        return window
    }
    
    func getWindowType() -> String{
        return self.windowConverter(window: self.getRawWindow())
    }
    
    func windowConverter(window: Window) -> String{
        switch window{
        case .topHung: return "Window hung from the top"
        case .bottomHung: return "Window hung from the bottom"
        case .leftHung: return "Window hung from the left"
        case .rightHung: return "Window hung from the right"
        case .sliding: return "Sliding Window"
        case .NA: return "N/A"
        default: return "Unknown Window Type"
        }
    }
    
    func getRawDoor() -> Door{
        return door
    }
    
    func getDoorType() -> String{
        return self.doorConverter(door: self.getRawDoor())
    }
    
    func doorConverter(door: Door) -> String{
        switch door{
        case .swing: return "Swinging Door"
        case .sliding: return "Sliding Door"
        case .NA: return "N/A"
        default: return "Unknown Door Type"
        }
    }
    
    func getRawOpen() -> Open{
        return open
    }
    
    func getOpenType() -> String{
        return self.openConverter(open: self.getRawOpen())
    }
    
    func openConverter(open: Open) -> String{
        switch open{
        case .closed: return "Closed"
        case .slight: return "Slightly Open"
        case .half: return "Half Open"
        case .open: return "Open"
        case .mostly: return "Mostly Open"
        case .NA: return "N/A"
        default: return "Unknown"
        }
    }
    
    func getLocation() -> simd_float3{
        return simd_make_float3(self.transform.columns.3)
    }
    
    func setLocation(location: simd_float3){
        self.transform.columns.3 = simd_make_float4(location)
        self.transform.columns.3[3] = 1
    }
    
    func getTransform() -> simd_float4x4{
        return self.transform
    }
    
    func setTransform(transform: simd_float4x4){
        self.transform = transform
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
    
    func getTag() -> Int{
        return self.tag
    }
    
    func setTag(tag: Int){
        self.tag = tag
    }
    
    func getOnCeiling() -> Bool{
        return self.onCeiling
    }
    
    func setOnCeiling(onCeiling: Bool){
        self.onCeiling = onCeiling
    }
    
    func getWidth() -> Float{
        return self.width
    }
    
    func setWidth(width: Float){
        self.width = width
    }
    
    func getHeight() -> Float{
        return self.height
    }
    
    func setHeight(height: Float){
        self.height = height
    }
}

