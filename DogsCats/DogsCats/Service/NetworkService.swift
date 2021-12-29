//
//  NetworkService.swift
//  DogsCats
//
//  Created by Булат Хабибуллин on 28.12.2021.
//

import Foundation
import Combine

class NetworkService {
    
    // MARK: Private properties
    
    private let dogsUrl = "https://dog.ceo/api/breeds/image/random"
    private let catsUrl = "https://catfact.ninja/fact"
    
    var dogsPublisher: AnyPublisher<Dog, Error> {
        guard let url = URL(string: dogsUrl) else {
            return Fail(error: URLError(.resourceUnavailable)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { $0.data }
            .decode(type: Dog.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    var catsPublisher: AnyPublisher<Cat, Error> {
        guard let url = URL(string: catsUrl) else {
            return Fail(error: URLError(.resourceUnavailable)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { $0.data }
            .decode(type: Cat.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
