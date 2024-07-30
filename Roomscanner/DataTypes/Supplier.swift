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
}
