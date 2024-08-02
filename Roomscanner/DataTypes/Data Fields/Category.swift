//
//  Category.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Category: String, CaseIterable, Identifiable{
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
    
    var stringValue: String{
        switch self{
        case .Sensor: return "Sensor"
        case .AirConditioning: return "Air Conditioner"
        case .Heater: return "Heater"
        case .Fan: return "Fan"
        case .AirSupply: return "Air Supplier"
        case .AirReturn: return "Air Return"
        case .AirExchange: return "Air Exchanger"
        case .DoorOpen: return "Door"
        case .WindowOpen: return "Window"
        }
    }
}
