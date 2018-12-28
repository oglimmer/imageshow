//
//  WaitingForEmailConfirmationViewController.swift
//  test
//
//  Created by Oli Zimpasser on 7/2/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit

class WaitingForEmailConfirmationViewController: UIViewController {

    @IBAction func onCancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tryAuth() {
        let email = GlobalUserData.email!
        let password = GlobalUserData.password!
        
        let postBody = "grant_type=password&client_id=genuine-web-client&email=\(email)&password=\(password)".data(using: String.Encoding.utf8)
        
        var request = URLRequest(url: URL(string: "http://192.168.1.152:3000/api/v1/auth/token")!)
        request.httpMethod = "POST"
        let task = URLSession.shared.uploadTask(with: request, from: postBody) { respData, response, error in
            if let error = error {
                print(error)
                return
            }
            let decoder = JSONDecoder()
            do {
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    print(retObj.error ?? "No error given!")
                    return
                }
                if let mimeType = httpResponse.mimeType, mimeType == "application/json" {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    if let returnCode = retObj.returnCode, returnCode == 101 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: self.tryAuth)
                    } else if retObj.access_token != nil {
                        GlobalUserData.access_token = retObj.access_token
                        DispatchQueue.main.async { self.performSegue(withIdentifier: "loggedInSegueFromWait", sender: nil) }
                    } else {
                        print("Illegal returnCode or something else...")
                    }
                } else {
                    print("something is wrong with the response")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: tryAuth)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
