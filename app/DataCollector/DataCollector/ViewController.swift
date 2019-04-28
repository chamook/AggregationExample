//
//  ViewController.swift
//  DataCollector
//
//  Created by Adam Guest on 05/04/2019.
//  Copyright © 2019 chamook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var headerView: UIView?
    var headerLabel: UILabel?
    var tableView: UITableView?
    
    var colours: [ColourWithItems] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    var dataFetcher: DataFetcher
    
    init(dataFetcher: DataFetcher) {
        self.dataFetcher = dataFetcher
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.installHeader()
        self.installTableView()
        
        self.dataFetcher.refreshData { [weak self] in
            guard let sself = self else { return }
            
            sself.colours = sself.dataFetcher.coloursAndItems
        }
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
                let items: [PricedItem] = colours[indexPath.item].items
                detailLabel.text = items.map{ "\($0.item.name) [\($0.price)]" }.joined(separator: ", ")
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}
