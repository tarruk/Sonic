//
//  AuthManager.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import Foundation


final class AuthManager {
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        static let clientID = "215b0b93a67e414789ca15ecf3569a85"
        static let clientSecret = "d3779e3eace74f51bb1d423b21a9c2ba"
        static let tokenApiURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://github.com/tarruk"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    struct Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let expirationDate = "expiration_date"
    }
    
    
    
    private init() {}
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: Keys.accessToken)
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: Keys.refreshToken)
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: Keys.expirationDate) as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    
   
    
    public func exchangeCodeForToken(
        code: String,
        completion: @escaping (Bool)->Void
    ) {
        
        //Get Token
        guard let url = URL(string: Constants.tokenApiURL) else {
            return
        }
        
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://github.com/tarruk")
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
    
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            debugPrint("Failure to get base64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
                
            }
            catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
    }
    
    private var onRefreshBlocks = [((String)->Void)]()
    
    ///Supplies valid token to be used with API calls
    public func withValidToken(completion: @escaping (String)->Void) {
        guard !refreshingToken else {
            //Append the completion
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            //Refresh
            refreshIfNeeded { [weak self] (success) in
                if success, let token = self?.accessToken {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool)->Void)?) {
        
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(false)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        //Refresh the token
        //Get Token
        guard let url = URL(string: Constants.tokenApiURL) else {
            return
        }
        
        refreshingToken = true
        
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
    
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            debugPrint("Failure to get base64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                debugPrint("Successfully refreshed")
                self?.onRefreshBlocks.forEach({$0(result.accessToken)})
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
                
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.accessToken, forKey: Keys.accessToken)
        if let refreshToken = result.refreshToken {
            UserDefaults.standard.setValue(refreshToken, forKey: Keys.refreshToken)
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: Keys.expirationDate)
    }
    
}
