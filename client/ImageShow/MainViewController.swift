//
//  MainViewController.swift
//  test
//
//  Created by Oli Zimpasser on 7/28/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToMainView(_ segue:UIStoryboardSegue) {
        for subv in tableView.subviews {
            if let utv = subv as? UITableView {
                if let con = utv.next as? TableViewController {
                    con.loadFromServer()
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
