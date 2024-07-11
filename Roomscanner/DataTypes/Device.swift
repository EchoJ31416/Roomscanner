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
    private enum category: String, CaseIterable{
        case sensor
        case airConditioning
        case heater
        case fan
        case airSupply
        case airReturn
        case airExchange
        case doorOpen
        case windowOpen
        
    }
    
    init(location: simd_float3, tag: Int = 0, onCeiling: Bool = false, size: Float = 0){
        self.location = location
        self.tag = tag
        self.onCeiling = onCeiling
        self.size = size
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

