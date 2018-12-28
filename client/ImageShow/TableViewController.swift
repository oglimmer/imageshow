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
        print("TableViewController::loadFromServer")
        data = []
        RemoteAccess.get("picturegroups", jsonReturnType: [JsonResult].self) { data in
            for jsonResult in data {
                for pic in jsonResult.picture_ref {
                    print("adding pic \(pic)")
                    let url = URL(string: "http://192.168.1.152:3000/api/v1/pictures/\(pic)?height=200")
                    let dataImage = try! Data(contentsOf: url!)
                    let cd = CellData.init(imageUUID: pic, message: pic, image: UIImage(data: dataImage))
                    self.data.append(cd)
                }
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.rowHeight = UITableViewAutomaticDimension
        // tableView.estimatedRowHeight = 250
        loadFromServer()
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "custom")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("TableViewController::tableView::cellForRowAt")
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "custom") as! CustomCell
        if let image = data[indexPath.row].image {
            cell.mainImage = image
        }
        cell.messsage = data[indexPath.row].message
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
}



