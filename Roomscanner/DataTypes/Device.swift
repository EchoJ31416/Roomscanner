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
    enum category: String, CaseIterable, Identifiable{
        case Sensor
        case AirConditioning
        case Heater
        case Fan
        case AirSupply
        case AirReturn
        case AirExchange
        case DoorOpen
        case WindowOpen
        
        var id: Self { self }
    }
    private var type = category.Sensor
    
    enum directions: String, CaseIterable, Identifiable{
        case Up
        case Down
        case Left
        case Right
        case Towards
        case Away
        case NA
        
        var id: Self { self }
    }
    private var direction = directions.NA
    
    enum conditioningType: String, CaseIterable, Identifiable{
        case window
        case split
        case NA
        
        var id: Self { self }
    }
    private var conditioner = conditioningType.NA
    
    enum supplyType: String, CaseIterable, Identifiable{
        case sameRoom
        case sharedAir
        case mixedAir
        case freshAir
        case NA
        
        var id: Self { self }
    }
    private var supplier = supplyType.NA
    
    enum windowType: String, CaseIterable, Identifiable{
        case leftHung
        case rightHung
        case topHung
        case bottomHung
        case sliding
        case NA
        
        var id: Self { self }
    }
    private var window = windowType.NA
    
    enum doorType: String, CaseIterable, Identifiable{
        case sliding
        case swing
        case NA
        
        var id: Self { self }
    }
    private var door = doorType.NA
    
    enum openCondition: String, CaseIterable, Identifiable{
        case closed
        case slight
        case half
        case open
        case mostly
        case NA
        
        var id: Self { self }
    }
    private var open = openCondition.NA
    
    init(
         transform: simd_float4x4 = simd_float4x4(0),
         tag: Int = 0,
         onCeiling: Bool = false,
         airSource: String = "",
         width: Float = 0,
         height: Float = 0,
         type: category = category.Sensor,
         direction: directions = directions.NA,
         conditioner: conditioningType = conditioningType.NA,
         supplier: supplyType = supplyType.NA,
         window: windowType = windowType.NA,
         door: doorType = doorType.NA,
         open: openCondition = openCondition.NA)
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
    
    func getRawType() -> category{
        return type
    }
    
    func getType() -> String{
        return self.categoryConverter(category: self.getRawType())
    }
    
    func categoryConverter(category: Device.category) -> String{
        switch category {
        case .Sensor: return "Sensor"
        case .AirConditioning: return "Air Conditioner"
        case .Heater: return "Heater"
        case .Fan: return "Fan"
        case .AirSupply: return "Air Supplier"
        case .AirReturn: return "Air Return"
        case .AirExchange: return "Air Exchanger"
        case .DoorOpen: return "Open door"
        case .WindowOpen: return "Open window"
        default: return "Unknown Device"
        }
    }
    
    func getAirSource() -> String{
        return airSource
    }
    
    func getRawConditioner() -> conditioningType{
        return conditioner
    }
    
    func getConditionerType() -> String{
        return self.conditionerConverter(conditioner: self.getRawConditioner())
    }
    
    func conditionerConverter(conditioner: Device.conditioningType) -> String{
        switch conditioner {
        case .window: return "Window Air Conditioner"
        case .split: return "Split Air Conditioner"
        case .NA: return "N/A"
        default: return "Unknown Air Conditioner"
        }
    }
    
    func getRawDirection() -> directions{
        return direction
    }
    
    func getDirection() -> String{
        return self.directionConverter(direction: self.getRawDirection())
    }
    
    func directionConverter(direction: Device.directions) -> String{
        if (direction == .NA){
            return "N/A"
        } else {
            return direction.rawValue
        }
    }
    
    func getRawSupplier() -> supplyType{
        return supplier
    }
    
    func getSupplierType() -> String{
        return self.supplierConverter(supplier: self.getRawSupplier())
    }
    
    func supplierConverter(supplier: Device.supplyType) -> String{
        switch supplier{
        case .sameRoom: return "Same room recirculation"
        case .sharedAir: return "Shared recirculated air"
        case .mixedAir: return "Mix of recirculated and fresh air"
        case .freshAir: return "Fresh Air"
        case .NA: return "N/A"
        default: return "Unknown Air Supplier"
        }
    }
    
    func getRawWindow() -> windowType{
        return window
    }
    
    func getWindowType() -> String{
        return self.windowConverter(window: self.getRawWindow())
    }
    
    func windowConverter(window: Device.windowType) -> String{
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
    
    func getRawDoor() -> doorType{
        return door
    }
    
    func getDoorType() -> String{
        return self.doorConverter(door: self.getRawDoor())
    }
    
    func doorConverter(door: Device.doorType) -> String{
        switch door{
        case .swing: return "Swinging Door"
        case .sliding: return "Sliding Door"
        case .NA: return "N/A"
        default: return "Unknown Door Type"
        }
    }
    
    func getRawOpen() -> openCondition{
        return open
    }
    
    func getOpenType() -> String{
        return self.openConverter(open: self.getRawOpen())
    }
    
    func openConverter(open: Device.openCondition) -> String{
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

