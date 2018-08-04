//
//  PortalViewController.swift
//  test
//
//  Created by Oli Zimpasser on 7/2/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit

struct JSONResponseData : Decodable {
    var returnCode: Int?
    var error: String?
    var access_token: String?
    var expires_in: Int?
}


class PortalViewController: UIViewController {

    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func unwindFromRegisterToPortal(_ segue:UIStoryboardSegue) {
        self.infoLabel.text = ""
    }
    
    @IBAction func clickLoginButton(_ sender: Any) {
                
        let email = emailField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let password = passwordField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let postBody = "grant_type=password&client_id=genuine-web-client&email=\(email)&password=\(password)".data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: URL(string: "https://image.oglimmer.de/api/v1/auth/token")!)
        request.httpMethod = "POST"
        let task = URLSession.shared.uploadTask(with: request, from: postBody) { respData, response, error in
            if let error = error {
                DispatchQueue.main.async { self.infoLabel.text = error.localizedDescription }
                return
            }
            let decoder = JSONDecoder()
            do {
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    DispatchQueue.main.async { self.infoLabel.text = retObj.error ?? "No error given!" }
                    return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "application/json" {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    if let returnCode = retObj.returnCode, returnCode == 101 {
                        DispatchQueue.main.async {
                            GlobalUserData.email = self.emailField.text
                            GlobalUserData.password = self.passwordField.text
                            self.performSegue(withIdentifier: "toWaitingSeguePortal", sender: nil)
                        }
                    } else if retObj.access_token != nil {
                        GlobalUserData.access_token = retObj.access_token
                        DispatchQueue.main.async {
                            GlobalUserData.email = self.emailField.text
                            GlobalUserData.password = self.passwordField.text
                            self.performSegue(withIdentifier: "loggedInSegue", sender: nil)
                        }
                    } else {
                        DispatchQueue.main.async { self.infoLabel.text = "Illegal returnCode or something else..." }
                    }
                } else {
                    DispatchQueue.main.async { self.infoLabel.text = "something is wrong with the response" }
                }
            } catch {
                DispatchQueue.main.async { self.infoLabel.text = error.localizedDescription }
            }
        }
        task.resume()
    }
    
}
