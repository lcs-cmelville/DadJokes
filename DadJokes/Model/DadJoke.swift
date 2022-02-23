//
//  DadJoke.swift
//  DadJokes
//
//  Created by Claire Coding Account on 2022-02-22.
//

import Foundation

//The DadJoke structure conforms to the decodable protocol. This means that we want Swift to be able to take a JSON object and 'decode' into an instance of this structure
struct DadJoke: Decodable, Hashable {
    let id: String
    let joke: String
    let status: Int
}
