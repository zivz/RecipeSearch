//
//  RecipeSearchClient.swift
//  RecipeSearch
//
//  Created by Ziv Zalzstein on 08/09/2018.
//  Copyright © 2018 Ziv. All rights reserved.
//

import Foundation

class RecipeSearchClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // uniqueKey state
    var uniqueKey: String? = nil
    var objectId: String? = nil
    //var students: [OTMStudent] = [OTMStudent]()
    
    // MARK: Initalizires
    
    override init(){
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(imageURL: String = "", parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //If Method is needed add in taskForGETMethod >>> _ method: String <<<
        
        /*2/3. Build the URL, Configure the request */
        
        var request: URLRequest
        
        if imageURL == "" {
            request = NSMutableURLRequest(url: recipeSearchURLFromParameters(parameters)) as URLRequest
            print("**********This is the request********")
            print(request)
        } else {
            request = URLRequest(url: URL(string: imageURL)!)
        }
       
        /*4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No Data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /*7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    /*func taskForPOSTMethod(_ method: String, _ apiHost: String, _ apiPath: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        //let parameters = [String:AnyObject]()
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: otmURLFromParameters(parameters, apiHost, apiPath, withPathExtension: method))
        request.httpMethod = "POST"
        
        if apiHost == Constants.Parse.ApiHost {
            request.addValue(Constants.Parse.ApiKey, forHTTPHeaderField: HttpHeaderFields.Parse.APIKey)
            request.addValue(Constants.Parse.AppId, forHTTPHeaderField: HttpHeaderFields.Parse.AppId)
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No Data was returned by the request!")
                return
            }
            
            var newData = data
            
            if apiHost == Constants.Udacity.ApiHost {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range) /* subset response data! */
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /*7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    func taskForPUTMethod(_ method: String, _ apiHost: String, _ apiPath: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: otmURLFromParameters(parameters, apiHost, apiPath, withPathExtension: method))
        request.httpMethod = "PUT"
        
        if apiHost == Constants.Parse.ApiHost {
            request.addValue(Constants.Parse.ApiKey, forHTTPHeaderField: HttpHeaderFields.Parse.APIKey)
            request.addValue(Constants.Parse.AppId, forHTTPHeaderField: HttpHeaderFields.Parse.AppId)
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No Data was returned by the request!")
                return
            }
            
            var newData = data
            
            if apiHost == Constants.Udacity.ApiHost {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range) /* subset response data! */
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPUT)
        }
        
        /*7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    func taskForDeleteMethod(_ method: String, _ apiHost: String, _ apiPath: String, parameters: [String:AnyObject], completionHandlerForDelete: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: otmURLFromParameters(parameters, apiHost, apiPath, withPathExtension: method))
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            /*if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet {
             self
             }*/
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDelete(nil, NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No Data was returned by the request!")
                return
            }
            
            var newData = data
            
            print("Got data")
            
            if apiHost == Constants.Udacity.ApiHost {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range) /* subset response data! */
                print("subset")
            }
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDelete)
        }
        
        /*7. Start the request */
        task.resume()
        
        return task
    }
    */
    //MARK : Helpers
    
    // subsitute the key for the value that is contained within the method name
    func substitueKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // given the JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            print("Printing parsed Result", parsedResult)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain:"convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a URL From Parameters
    private func recipeSearchURLFromParameters(_ parameters: [String:AnyObject], _ url: String = "") -> URL {
        
        var components = URLComponents()
        components.scheme = RecipeSearchClient.Constants.ApiScheme
        components.host = RecipeSearchClient.Constants.ApiHost
        components.path = RecipeSearchClient.Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        components.queryItems!.append(URLQueryItem(name: ParameterKeys.AppId, value: Constants.AppId))
        components.queryItems!.append(URLQueryItem(name: ParameterKeys.AppKey, value: Constants.ApiKey))
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            print("Query item is : \(queryItem)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> RecipeSearchClient {
        struct Singleton {
            static var sharedInstance = RecipeSearchClient()
        }
        return Singleton.sharedInstance
    }
    
}
