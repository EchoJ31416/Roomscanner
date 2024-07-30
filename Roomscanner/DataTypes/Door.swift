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
}
