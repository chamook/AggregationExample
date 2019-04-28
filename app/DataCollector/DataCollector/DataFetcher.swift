//
//  DataFetcher.swift
//  DataCollector
//
//  Created by Adam Guest on 27/04/2019.
//  Copyright © 2019 chamook. All rights reserved.
//

import Foundation

typealias Completion = () -> Void

class DataFetcher {
    
    private var colours: [Colour]
    private var items: Dictionary<String, [Item]>
    private var prices: [Price]
    
    public var coloursAndItems: [ColourWithItems] {
        var result: [ColourWithItems] = []
        
        for colour in self.colours {
            let colourItems = self.items[colour.id]
            var pricedItems: [PricedItem] = []
            
            for item in colourItems ?? [] {
                if let price = self.prices.first(where: { $0.itemId == item.id }) {
                    pricedItems.append(PricedItem(item: item, price: price.price))
                }
            }
            
            result.append(ColourWithItems(colour: colour, items: pricedItems))
        }
        
        return result
    }
    
    init() {
        self.colours = []
        self.items = Dictionary<String, [Item]>()
        self.prices = []
    }
    
    func getMyColours(completion: Completion? = nil) {
        struct ColourDto: Decodable {
            var colours: [Colour]
        }
        
        let myColoursUrl = URL(string: "http://localhost:8081/my-colours")!
        var request = URLRequest(url: myColoursUrl)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                print("Error getting colours")
                return
            }
            guard let content = data else {
                print("Couldn't get any colours")
                return
            }
            
            do {
                let colourData = try JSONDecoder().decode(ColourDto.self, from: content)
                self?.colours = colourData.colours
                
                completion?()
            } catch let err {
                print(err)
            }
        }.resume()
    }
    
    func getItemsFor(colour: Colour, completion: Completion? = nil) {
        struct ItemDto: Decodable {
            var items: [Item]
        }
        
        let itemsUrl = URL(string: "http://localhost:8082/items/\(colour.id)")!
        URLSession.shared.dataTask(with: itemsUrl) { [weak self] (data, response, error) in
            guard error == nil else {
                print("Error getting items for \(colour.id)")
                return
            }
            guard let content = data else {
                print("Couldn't get any items for \(colour.id)")
                return
            }
            
            do {
                let itemData = try JSONDecoder().decode(ItemDto.self, from: content)
                self?.items[colour.id] = itemData.items
                
                completion?()
            } catch let err {
                print(err)
            }
        }.resume()
    }
    
    func getAllItems(completion: Completion? = nil) {
        let itemGroup = DispatchGroup()
        
        for colour in self.colours {
            itemGroup.enter()
            self.getItemsFor(colour: colour) { itemGroup.leave() }
        }
        
        itemGroup.notify(queue: .main) { completion?() }
    }
    
    func getPriceFor(item: Item, completion: Completion? = nil) {
        let priceUrl = URL(string: "http://localhost:8083/item/\(item.id)/price")!
        URLSession.shared.dataTask(with: priceUrl) { [weak self] (data, response, error) in
            guard error == nil else {
                print("Error getting price for \(item.id)")
                return
            }
            guard let content = data else {
                print("Could not get price for item: \(item.id)")
                return
            }
            
            do {
                let priceData = try JSONDecoder().decode(Price.self, from: content)
                self?.prices.append(priceData)
                
                completion?()
            } catch let err {
                print(err)
            }
        }.resume()
    }
    
    func getAllPrices(completion: Completion? = nil) {
        let priceGroup = DispatchGroup()
        
        for item in self.items.flatMap({ $0.value }) {
            priceGroup.enter()
            self.getPriceFor(item: item) { priceGroup.leave() }
        }
        
        priceGroup.notify(queue: .main) { completion?() }
    }
    
    public func refreshData(completion: Completion? = nil) {
        self.getMyColours { [weak self] () in
            guard let sself = self else { return }
            sself.getAllItems { [weak self] () in
                guard let sself = self else { return }
                sself.getAllPrices { completion?() }
            }
        }
    }
}
