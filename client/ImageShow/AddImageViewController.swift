//
//  AddImageViewController.swift
//  test
//
//  Created by Oli Zimpasser on 7/29/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import UIKit
import Photos

struct PictureGroupsSummaryResponse : Decodable {
    let _id : String
    let name : String
}

enum ValiationError: Error {
    case newGroupEmptyName
}

class AddImageViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    URLSessionDownloadDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imagePicked: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var newGroupName: UITextField!
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var existingGroups: [PictureGroupsSummaryResponse] = [PictureGroupsSummaryResponse(_id: "0", name: "Create new group")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        imagePicked.alpha = 1
        progressBar.isHidden = true
        
        RemoteAccess.get("picturegroups/summary", jsonReturnType: [PictureGroupsSummaryResponse].self) { data in
            self.existingGroups.append(contentsOf: data)
            DispatchQueue.main.async {
                self.groupPicker.reloadAllComponents()
            }
        }
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async {
            self.progressBar.setProgress(Float.init(totalBytesSent) / Float.init(totalBytesExpectedToSend), animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return existingGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return existingGroups[row].name
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }

    @IBAction func onAddClicked(_ sender: Any) {
        //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //            let imagePicker = UIImagePickerController()
        //            imagePicker.delegate = self
        //            imagePicker.sourceType = .camera;
        //            imagePicker.allowsEditing = false
        //            self.present(imagePicker, animated: true, completion: nil)
        //        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSaveClicked(_ sender: Any) {
        do {
        let imageData = UIImageJPEGRepresentation(imagePicked.image!, 1)
                
        let url = URL(string: "http://192.168.1.152:3000/api/v1/pictures")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(GlobalUserData.access_token!)", forHTTPHeaderField: "authorization")
        request.addValue("test", forHTTPHeaderField: "x_filename")
        request.addValue(self.commentField.text!, forHTTPHeaderField: "x_comment")
        let selectedRow = self.groupPicker.selectedRow(inComponent: 0)
        if selectedRow != 0 {
            let groupRef = self.existingGroups[selectedRow]._id
            request.addValue(groupRef, forHTTPHeaderField: "x_groupref")
        } else {
            if self.newGroupName.text!.isEmpty {
                throw ValiationError.newGroupEmptyName
            }
            request.addValue(self.newGroupName.text!, forHTTPHeaderField: "x_grouprefname")
        }
        request.addValue("image/jpeg", forHTTPHeaderField: "content-type")
        activityIndicator.isHidden = false
        imagePicked.alpha = 0.3
        progressBar.isHidden = false
        progressBar.setProgress(0, animated: false)
        
        let task = urlSession.uploadTask(with: request, from: imageData) { respData, response, error in
            if let error = error {
                print(error)
                return
            }
            // let decoder = JSONDecoder()
            // do {
                guard let httpResponse = response as? HTTPURLResponse else {
                    fatalError("Response is not of type http.")
                }
                if (200...299).contains(httpResponse.statusCode), let mimeType = httpResponse.mimeType, mimeType == "application/json" {
                    // print(String(data: respData!, encoding: .utf8))
                    // let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    // print(retObj)
                } else {
                    print("something is wrong with the response")
                }
            // } catch {
            //     print(error.localizedDescription)
            // }
            DispatchQueue.main.async {
                 self.performSegue(withIdentifier: "unwindToMainSegue", sender: nil)
            }
        }
        task.resume()
        }
        catch {
            let alert = UIAlertController(title: "Error while saving", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
