//
//  RegisterViewController.swift
//  test
//
//  Created by Oli Zimpasser on 7/2/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password1Field: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func clickRegisterButton(_ sender: Any) {
        self.infoLabel.text = ""
        if (emailField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
            self.infoLabel.text = "Email must not be empty!"
            return;
        }
        if (password1Field.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty) {
            self.infoLabel.text = "Password must not be empty!"
            return;
        }
        if (password1Field.text != password2Field.text) {
            self.infoLabel.text = "Confirm password does NOT match!"
            return;
        }

        let email = emailField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let password = password1Field.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let postBody = "email=\(email)&password=\(password)".data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: URL(string: "https://image.oglimmer.de/api/v1/users")!)
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
                        GlobalUserData.email = self.emailField.text
                        GlobalUserData.password = self.password1Field.text
                        DispatchQueue.main.async { self.performSegue(withIdentifier: "toWaitingSegue", sender: nil) }
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
