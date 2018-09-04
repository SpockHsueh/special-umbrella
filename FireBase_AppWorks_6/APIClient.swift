//
//  APIClient.swift
//  FireBase_AppWorks_6
//
//  Created by Spoke on 2018/9/3.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    
    typealias userInfo = (Bool?, Error?) -> Void
    
    func findUser(completionHandler completion: @escaping userInfo) {
        
        let findUserURL: URL = URL(string: "https://fir-appworks-project6.firebaseio.com")!
//        let headers = [ "Authorization": "Bearer \(userManger)" ]
        
        Alamofire.request(findUserURL, method: .get).validate().responseData { (response) in
            
            guard response.result.isSuccess else {
                let errorMessage = response.result.error
                completion(nil, errorMessage)
                return
            }
            completion(true, nil)
        }
        
    }
    
}
