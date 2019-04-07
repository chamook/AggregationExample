//
//  ViewController.swift
//  DataCollector
//
//  Created by Adam Guest on 05/04/2019.
//  Copyright © 2019 chamook. All rights reserved.
//

import UIKit

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

struct ColourWithItems {
    var colour: Colour
    var items: [Item]
}

class ViewController: UIViewController {
    
    var headerView: UIView?
    var headerLabel: UILabel?
    var tableView: UITableView?
    
    var colours: [ColourWithItems] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.installHeader()
        self.installTableView()
        
        self.loadColours()
    }

    private func loadColours() {
        struct ColourDto: Decodable {
            var colours: [Colour]
        }
        struct ItemDto: Decodable {
            var items: [Item]
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
                for colour in colourData.colours {
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
                            self?.colours.append(ColourWithItems(colour: colour, items: itemData.items))
                            
                            DispatchQueue.main.async {
                                self?.tableView?.reloadData()
                            }
                        } catch let err {
                            print("Error decoding item json", err)
                        }
                    }.resume()
                }
                
            } catch let err {
                print("Error decoding colour json", err)
            }
        }.resume()
    }
    
    private func installTableView() {
        guard let header = self.headerView else {
            return
        }

        let table = UITableView()
        table.backgroundColor = .white
        self.view.addSubview(table)

        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        table.dataSource = self
        self.tableView = table
    }

    private func installHeader() {
        let header = UIView()
        header.backgroundColor = .white
        self.view.addSubview(header)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        
        let label = UILabel()
        label.text = "My Colours"
        label.textAlignment = .center
        header.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        
        self.headerView = header
        self.headerLabel = label
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "colour")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "colour")
        }
        
        if let cell = cell {
            cell.backgroundColor = .white
            
            if let label = cell.textLabel {
                let colour = colours[indexPath.item].colour
                label.text = "\(colour.name) (\(colour.hex))"
                label.textColor = UIColor.init(red: CGFloat(colour.rgb.red), green: CGFloat(colour.rgb.green), blue: CGFloat(colour.rgb.blue), alpha: CGFloat(1))
            }
            
            if let detailLabel = cell.detailTextLabel {
                let items: [Item] = colours[indexPath.item].items
                detailLabel.text = items.map{ $0.name }.joined(separator: ", ")
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}
