//
//  Cat.swift
//  DogsCats
//
//  Created by Булат Хабибуллин on 28.12.2021.
//

import Foundation

struct Cat: Decodable {
    
    let fact: String?
    
    init(fact: String? = nil) {
        self.fact = fact
    }
}
