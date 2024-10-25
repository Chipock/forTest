//
//  UserService.swift
//  CombineForTest
//
//  Created by Vadim Volyas on 25.10.2024.
//

import Foundation
import Combine

class UserService {
    func obtainUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "google.com")
        return URLSession.shared.dataTaskPublisher(for: url!)
            .map(\.data)
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
