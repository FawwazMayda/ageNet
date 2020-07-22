//
//  Network.swift
//  ageNet
//
//  Created by Muhammad Fawwaz Mayda on 22/07/20.
//  Copyright © 2020 Muhammad Fawwaz Mayda. All rights reserved.
//

import UIKit
import Alamofire

struct FaceError: Codable {
    
    var request_id : String
    var error_message: String
    
}
struct FaceResult: Codable {
 
    var face_rectangle : FaceRectangle
    var request_id : String
    var result: Result
}

struct Result: Codable {

    var acne: ResultConf
    var forehead_wrinkle: ResultConf
    
    
}
struct FaceRectangle: Codable {
 
    var width: Int
    var top: Int
    var height: Int
    var left: Int
}

struct ResultConf: Codable {
   
    var confidence: Double
    var value: Int
}

class NetReq {
    static let baseURL = "https://api-us.faceplusplus.com/facepp/v1/skinanalyze"
    static let api_key = "m3LyTxPWo6PpBU-l6TBFnr9_pJTXb4V_"
    static let api_secret = "CSnDqDH7i2rZEc8EFBlFn3l8X_6dUSBM"
    var acneLabel = UILabel()
    var wrinkleLabel = UILabel()
    func doRequests(withImage: UIImage) {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        
        var requests = URLRequest(url: URL(string: NetReq.baseURL)!)
        requests.httpMethod = "POST"
        requests.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        requests.addValue("multipart/form-data", forHTTPHeaderField: "Accept")
        
        guard let data = withImage.jpegData(compressionQuality: 0.9) else {fatalError("error the JPEG Data")}
        
        
        let params : [String:String] = ["api_secret":NetReq.api_secret,
                      "api_key":NetReq.api_key,
                      "image_base64": data.base64EncodedString()]
        
        requests.httpBody = createReqBody(params: params, imageField: "image_file", filename: "image.jpg", using: boundary)
        
        let task = URLSession.shared.dataTask(with: requests) { (data, resp, error) in
            if let res = resp {
                print(res)
            }
            
            if let retrievedData = data {
                self.decodeData(result: retrievedData)
            }
            
        }
        task.resume()
    }
    
    func createReqBody(params: [String:String],imageField: String,filename: String,using boundary: String) -> Data {
        var fieldString = "--\(boundary)\r\n"
        
        for (key,value) in params {
            /*
            if key==imageField {
                let mimeType = "image/jpg"
                fieldString += "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n"
                fieldString += "Content-Type: \(mimeType)\r\n\r\n"
                fieldString += "\r\n"
                fieldString += "\(value)\r\n"
            } else {
                fieldString += "Content-Disposition: form-data; name=\"\(key)\"\r\n"
                fieldString += "\r\n"
                fieldString += "\(value)\r\n"
            }*/
            fieldString += "Content-Disposition: form-data; name=\"\(key)\"\r\n"
            fieldString += "\r\n"
            fieldString += "\(value)\r\n"
        }
        
        fieldString += "--Boundary-\(boundary)--"
        print(fieldString)
        if let data = fieldString.data(using: .utf8) {
            print("Param is encoded")
            return data
        }
        return Data()
    }
    
    func decodeData(result: Data) {
        do {
            let faceResultDetail = try JSONDecoder().decode(FaceError.self, from: result)
            
        } catch {
            print(error)
        }
    }
    
    func doRequestsAlamo(withImage: UIImage) {
        guard let imgData = withImage.jpegData(compressionQuality: 0.9) else {fatalError("Fail to get JPEG")}
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        let req = AF.upload(multipartFormData: { multiForm in
            multiForm.append(imgData, withName: "image_file", fileName: "upload.jpeg", mimeType: "image/jpeg")
            multiForm.append(NetReq.api_key.data(using: .utf8)!, withName: "api_key")
            multiForm.append(NetReq.api_secret.data(using: .utf8)!, withName: "api_secret")
            
        }, to: NetReq.baseURL, usingThreshold: UInt64.init(), method: .post, headers: headers)
        
        req.response { res in
            print(res)
            if let retrievedData = res.data {
                do {
                    let faceResultDetail = try! JSONDecoder().decode(FaceResult.self, from: retrievedData)
                    print(faceResultDetail.request_id)
                    print(faceResultDetail)
                    DispatchQueue.main.async {
                        self.acneLabel.text = "Acne: \(faceResultDetail.result.acne.confidence)"
                        self.wrinkleLabel.text = "Wrinkle: \(faceResultDetail.result.forehead_wrinkle.confidence)"
                    }
                }
            }
        }
        
    }
}
