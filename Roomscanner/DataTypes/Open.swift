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
}
