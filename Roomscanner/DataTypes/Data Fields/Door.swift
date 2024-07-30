//
//  Door.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Door: String, CaseIterable, Identifiable{
    case sliding
    case swing
    case NA
    
    var id: Self { self }
    
    var stringValue: String{
        switch self{
        case .swing: return "Swinging Door"
        case .sliding: return "Sliding Door"
        case .NA: return "N/A"
        }
    }
}
