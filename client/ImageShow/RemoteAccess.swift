//
//  RemoteAccess.swift
//  ImageShow
//
//  Created by Oli Zimpasser on 7/29/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import Foundation


class RemoteAccess {
    
    static func get<T: Decodable>(_ area : String, jsonReturnType type : T.Type, completion completionFunc: @escaping (T) -> Void) {
        let url = URL(string: "http://192.168.1.152:3000/api/v1/\(area)")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(GlobalUserData.access_token!)", forHTTPHeaderField: "authorization")
        let task = URLSession.shared.dataTask(with: request) { respData, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Response is not of type http")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType != "application/json" {
                print("Response does not return json")
                return
            }
            let decoder = JSONDecoder()
            do {
                if (200...299).contains(httpResponse.statusCode) {
                    let retObj = try decoder.decode(type, from: respData!)
                    completionFunc(retObj)
                } else {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    print(retObj.error ?? "No error given!")
                }
            } catch {
                print("Error in RemoteAccess::get")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    static func post<T: Decodable>(_ area : String, jsonReturnType type : T.Type, postData imageData : Data, additionalHeaders headers : [String: String], completion completionFunc: @escaping (T) -> Void) {
        let url = URL(string: "http://192.168.1.152:3000/api/v1/\(area)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(GlobalUserData.access_token!)", forHTTPHeaderField: "authorization")
        for header in headers {
            request.addValue(header.key, forHTTPHeaderField: header.value)
        }
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { respData, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Response is not of type http")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType != "application/json" {
                print("Response does not return json")
                return
            }
            let decoder = JSONDecoder()
            do {
                if (200...299).contains(httpResponse.statusCode) {
                    let retObj = try decoder.decode(type, from: respData!)
                    completionFunc(retObj)
                } else {
                    let retObj = try decoder.decode(JSONResponseData.self, from: respData!)
                    print(retObj.error ?? "No error given!")
                }
            } catch {
                print("Error in RemoteAccess::get")
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
