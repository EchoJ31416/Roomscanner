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
    private var tag: Int
    private var onCeiling: Bool
    private var size: Float
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
    
    enum conditioningType: String, CaseIterable, Identifiable{
        case window
        case split
        
        var id: Self { self }
    }
    
    enum supplyType: String, CaseIterable, Identifiable{
        case freshAirDuct
        case exhaustAirDuct
        case supplyAirDuct
        
        var id: Self { self }
    }
    
    init(location: simd_float3 = simd_make_float3(0, 0, 0), tag: Int = 0, onCeiling: Bool = false, size: Float = 0, type: category = category.Sensor){
        self.location = location
        self.tag = tag
        self.onCeiling = onCeiling
        self.size = size
        self.type = type
    }
    
    func getLocation() -> simd_float3{
        return self.location
    }
    
    func setLocation(location: simd_float3){
        self.location = location
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
    
    func getSize() -> Float{
        return self.size
    }
    
    func setSize(size: Float){
        self.size = size
    }
}

