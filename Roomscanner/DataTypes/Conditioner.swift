//
//  Conditioner.swift
//  Roomscanner
//
//  Created by User on 30/7/2024.
//

import Foundation

enum Conditioner: String, CaseIterable, Identifiable{
    case window
    case split
    case NA
    
    var id: Self { self }
}
