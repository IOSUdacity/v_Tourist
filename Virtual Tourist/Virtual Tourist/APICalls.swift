//
//  APICalls.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/6/22.
//

import Foundation
import UIKit

class APICalls: Codable {
    
    class func flickrDownload<ResponseType: Decodable>(urlReq: URLRequest, responseStructure: ResponseType.Type, completion: @escaping(ResponseType?, Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: urlReq){
            (data, response, error) in
          //  print("Printing Response"); print(response); print("\n\n"); print("Heres is the data"); print(data); print("\n\n")
            guard error == nil else{
                print("In Error guard, error:"); print(error)
                completion(nil, error)
                return
            }
           
            var stringData = String(data: data!, encoding: .utf8)
    //        print("Printing stringData downloaded"); print(stringData)
            
           let decoder = JSONDecoder()
            do{
           let decodedData = try decoder.decode(ResponseType.self, from: data!)
                print("Printing Decoded Data"); print(decodedData)
            
           completion(decodedData, error)
            }catch{
                completion(nil, error)
            }
        }
        task.resume()
        return
    }
    
    class func downloadImage(urlReq: URL, completition: @escaping (Data?, Error?) ->Void){
        var urlRequest = URLRequest(url: urlReq)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data, response, error) in
            guard let data = data else{
                print("Error in downloading Image")
                print(error)
                completition(nil, error)
                return
            }
            completition(data, error)
            
        }
        task.resume()
        
    }
    
    struct flickrPhoto: Codable{
        var photos: flickrJSON
     
    }
        
    
    struct flickrJSON: Codable{
        var  page:Int
        var  pages:Int
        var total:Int
        var photo: [flickrPhotoInfo]
        var stat:String?
    }
    
    struct flickrPhotoInfo:Codable{
        var id: String
        var owner: String
        var secret: String
        var server: String
        var title:String
    }
    
}
