//
//  LoggerManager.swift
//  Sonic
//
//  Created by Tarek on 20/03/2021.
//

import Foundation

final class LoggerManager {
    static let shared = LoggerManager()
    
    private init() {}
    
    
    func printRequest(from request: URLRequest) {
        printLine()
        guard let url = request.url,
              let method = request.httpMethod else {
            return
        }
        print("Dispatch to  => \(url)")
        print("Method       => \(method)")
        print("Parameters   =>")
        if let params = request.httpBody {
            printJSON(from: params)
        }
        
    }
    
    func printLine() {
        print("----------------------------------------------")
    }
    

    func printJSON(from data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print(json)
        } catch {
            debugPrint("Logger Error on printJSON")
        }
    }
    
    func printJSON(from dict: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            print(decoded)
            // you can now cast it with the right typ
        } catch {
            print(error.localizedDescription)
        }

        
    }
    
    func printJSON<T: Codable>(from responseValue: T) {
        print("Response     =>")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(responseValue)
        print(String(data: data, encoding: .utf8)!)
        printLine()
        
    }
    
    func printStatusCode(from response: HTTPURLResponse){
        print("Status code  => \(response.statusCode)")
        
    }

    
    func printDecodingError() {
        print("Decoding error!!!")
    }
    
}
