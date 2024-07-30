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
}
