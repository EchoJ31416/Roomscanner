//
//  Window.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Window: String, CaseIterable, Identifiable{
    case leftHung
    case rightHung
    case topHung
    case bottomHung
    case sliding
    case NA
    
    var id: Self { self }
    
    var stringValue: String{
        switch self{
        case .topHung: return "Window hung from the top"
        case .bottomHung: return "Window hung from the bottom"
        case .leftHung: return "Window hung from the left"
        case .rightHung: return "Window hung from the right"
        case .sliding: return "Sliding Window"
        case .NA: return "N/A"
        }
    }
}
