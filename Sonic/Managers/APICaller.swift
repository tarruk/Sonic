//
//  APICaller.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    
    
    public func getCurrentUserProfile(completion: @escaping (Result<User, Error>)->Void) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/me"), type: .GET) { [weak self] baseRequest in
            
            self?.createTask(with: baseRequest, completion: {
                result in
                completion(result)
            })
        }
    }
    
    public func getRecommendedGenres(completion: @escaping(Result<RecommendedGenres, Error>) -> Void) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/recommendations/available-genre-seeds"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest, completion: { result in
                completion(result)
            })
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping(Result<Recommendation, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/recommendations?seed_genres=\(seeds)"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest, completion: { result in
                completion(result)
            })
        }
    }
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>) -> Void)) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/browse/new-releases"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest, completion: { result in
                completion(result)
            })
        }
    }
    
    public func getFeaturedPlaylist(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>)-> Void ) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/browse/featured-playlists"), type: .GET) { [weak self] request in
            self?.createTask(with: request, completion: { (result) in
                completion(result)
            })
        }
    }
    
    
    
    //MARK: - Private -
    
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest)->Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            
            completion(request)
        }
        
        
    }
    
    private func createTask<T: Codable>(with request : URLRequest, completion: @escaping (Result<T, Error>)->Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            
            LoggerManager.shared.printRequest(from: request)
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                print(json)
                let model = try JSONDecoder().decode(T.self, from: data)
                LoggerManager.shared.printJSON(from: model)
                completion(.success(model))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
}
