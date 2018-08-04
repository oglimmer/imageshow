//
//  ViewController.swift
//  test
//
//  Created by Oli Zimpasser on 6/16/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit

struct CellData {
    let imageUUID : String
    let message : String
    var image : UIImage?
}

struct JsonResult : Decodable {
    var _id : String
    var _rev : String
    var type : String
    var name : String
    var createdOn : String
    var lastUpdatedOn : String
    var user_ref : String
    var picture_ref : [String]
}

class TableViewController: UITableViewController {

    var data = [CellData]()

    func loadFromServer() {
        data = []
        RemoteAccess.get("picturegroups", jsonReturnType: [JsonResult].self) { data in
            for jsonResult in data {
                for pic in jsonResult.picture_ref {
                    let cd = CellData.init(imageUUID: pic, message: pic, image: nil)
                    self.data.append(cd)
                }
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        loadFromServer()
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        if let image = data[indexPath.row].image {
            cell.mainImage = image
        } else {
            DispatchQueue.global().async() {
                let imageUUID = self.data[indexPath.row].imageUUID;
                let url = URL(string: "https://image.oglimmer.de/api/v1/pictures/\(imageUUID)?height=200")
                let dataImage = try! Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.data[indexPath.row].image = UIImage(data: dataImage)
                    self.tableView.beginUpdates()
                    cell.mainImage = self.data[indexPath.row].image!
                    self.tableView.endUpdates()
                }
            }
        }
        cell.messsage = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
}



