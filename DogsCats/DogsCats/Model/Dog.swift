//
//  Dog.swift
//  DogsCats
//
//  Created by Булат Хабибуллин on 28.12.2021.
//

import Foundation

struct Dog: Decodable {
    
    let message: String?
    
    init(message: String? = nil) {
        self.message = message
    }
}
