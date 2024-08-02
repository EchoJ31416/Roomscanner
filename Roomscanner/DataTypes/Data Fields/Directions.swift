//
//  Directions.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Directions: String, CaseIterable, Identifiable{
    case Up
    case Down
    case Left
    case Right
    case Towards
    case Away
    case NA
    
    var id: Self { self }
    
    var stringValue: String{
        if (self == .NA){
            return "N/A"
        } else {
            return rawValue
        }
    }
}
