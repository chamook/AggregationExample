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

class ViewController: UIViewController {
    
    var headerView: UIView?
    var headerLabel: UILabel?
    var tableView: UITableView?
    
    var colours: [Colour] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.installHeader()
        self.installTableView()
        
        self.loadColours()
    }

    private func loadColours() {
        let url = URL(string: "http://localhost:5000/my-colours")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.chamook.api+json; including=id,name,hex,rgb", forHTTPHeaderField: "Accept")
        
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
                struct ColourDto: Decodable {
                    var colours: [Colour]
                }
                let colourData = try JSONDecoder().decode(ColourDto.self, from: content)
                self?.colours = colourData.colours
                
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            } catch let err {
                print("Error decoding json", err)
            }
        }.resume()
    }
    
    private func installTableView() {
        guard let header = self.headerView else {
            return
        }

        let table = UITableView()
        table.backgroundColor = .white
        table.register(UITableViewCell.self, forCellReuseIdentifier: "colour")
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "colour") {
            cell.backgroundColor = .white
            
            if let label = cell.textLabel {
                let colour = colours[indexPath.item]
                label.text = "\(colour.name) (\(colour.hex))"
                label.textColor = UIColor.init(red: CGFloat(colour.rgb.red), green: CGFloat(colour.rgb.green), blue: CGFloat(colour.rgb.blue), alpha: CGFloat(1))
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}
