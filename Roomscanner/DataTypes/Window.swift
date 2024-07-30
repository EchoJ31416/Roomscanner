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
}
