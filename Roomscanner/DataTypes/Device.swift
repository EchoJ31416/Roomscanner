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
    private var location: simd_float3
    private var rotation: simd_float3
    private var tag: Int
    private var onCeiling: Bool
    private var width: Float
    private var height: Float
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
        case freshAirDuct
        case exhaustAirDuct
        case supplyAirDuct
        case NA
        
        var id: Self { self }
    }
    private var supplier = supplyType.NA
    
    init(location: simd_float3 = simd_make_float3(0, 0, 0), 
         rotation: simd_float3 = simd_make_float3(0, 0, 0),
         tag: Int = 0,
         onCeiling: Bool = false,
         width: Float = 0,
         height: Float = 0,
         type: category = category.Sensor,
         direction: directions = directions.NA,
         conditioner: conditioningType = conditioningType.NA,
         supplier: supplyType = supplyType.NA)
    {
        self.location = location
        self.rotation = rotation
        self.tag = tag
        self.onCeiling = onCeiling
        self.width = width
        self.height = height
        self.type = type
        self.direction = direction
        self.conditioner = conditioner
        self.supplier = supplier
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
        case .freshAirDuct: return "Fresh Air Duct"
        case .exhaustAirDuct: return "Exhaust Air Duct"
        case .supplyAirDuct: return "Supply Air Duct"
        case .NA: return "N/A"
        default: return "Unknown Air Supplier"
        }
    }
    
    func getLocation() -> simd_float3{
        return self.location
    }
    
    func setLocation(location: simd_float3){
        self.location = location
    }
    
    func getRotation() -> simd_float3{
        return self.rotation
    }
    
    func setRotation(rotation: simd_float3){
        self.rotation = rotation
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

