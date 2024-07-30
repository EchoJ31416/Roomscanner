//
//  Supplier.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Supplier: String, CaseIterable, Identifiable{
    case sameRoom
    case sharedAir
    case mixedAir
    case freshAir
    case NA
    
    var id: Self { self }
    
    var stringValue: String{
        switch self{
        case .sameRoom: return "Same room recirculation"
        case .sharedAir: return "Shared recirculated air"
        case .mixedAir: return "Mix of recirculated and fresh air"
        case .freshAir: return "Fresh Air"
        case .NA: return "N/A"
        }
    }
}
