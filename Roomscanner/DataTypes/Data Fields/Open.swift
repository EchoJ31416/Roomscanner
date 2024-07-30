//
//  Open.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Open: String, CaseIterable, Identifiable{
    case closed
    case slight
    case half
    case open
    case mostly
    case NA
    
    var id: Self { self }
    
    var stringValue: String{
        switch self{
        case .closed: return "Closed"
        case .slight: return "Slightly Open"
        case .half: return "Half Open"
        case .open: return "Open"
        case .mostly: return "Mostly Open"
        case .NA: return "N/A"
        }
    }
}
