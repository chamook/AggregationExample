//
//  Types.swift
//  DataCollector
//
//  Created by Adam Guest on 27/04/2019.
//  Copyright © 2019 chamook. All rights reserved.
//

import Foundation

struct RGB: Decodable {
    var red: Int
    var green: Int
    var blue: Int
}

struct Colour: Decodable {
    var id: String
    var name: String
    var hex: String
    var rgb: RGB
}

struct Item: Decodable {
    var id: String
    var name: String
}

struct Price: Decodable {
    var itemId: String
    var price: Decimal
}

struct PricedItem {
    var item: Item
    var price: Decimal
}

struct ColourWithItems {
    var colour: Colour
    var items: [PricedItem]
}
