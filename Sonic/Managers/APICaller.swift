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
    
    //MARK: - Albums -
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetails, Error>)-> Void ) {
        guard let albumID = album.id else { return }
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/albums/\(albumID)"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest) { result in
                completion(result)
            }
        }
    }
    
    
    //MARK: - Playlists -
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetail, Error>)-> Void ) {
        guard let playlistID = playlist.id else { return }
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/playlists/\(playlistID)"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest) { result in
                completion(result)
            }
        }
    }
    
    //MARK: - Category
    
    public func getCategories() -> Single<[MusicCategory]> {
        return Single<[MusicCategory]>.create { [weak self] single -> Disposable in
            self?.createRequest(with: URL(string: "\(Constants.baseAPIURL)/browse/categories"), type: .GET) { baseRequest in
                self?.createTask(with: baseRequest, completion: { (result: Result<CategoriesResponse, Error>) in
                    switch result {
                    case .success(let categoriesResponse):
                        let categories = categoriesResponse.categories?.items ?? []
                        single(.success(categories))
                    case .failure(let error):
                        single(.failure(error))
                    }
                })
            }
            return Disposables.create()
        }
        
    }
    
    public func getCategoryPlaylists(category: MusicCategory) -> Single<[Playlist]> {
        return Single<[Playlist]>.create { [weak self] single -> Disposable in
            guard let categoryID = category.id else {
                return Disposables.create()
            }
            self?.createRequest(with: URL(string: "\(Constants.baseAPIURL)/browse/categories/\(categoryID)/playlists"), type: .GET) { baseRequest in
                self?.createTask(with: baseRequest, completion: { (result: Result<CategoryPlaylistsResponse, Error>) in
                    switch result {
                    case .success(let playlistsResponse):
                        let playlists = playlistsResponse.playlistsResponse?.playlists
                        single(.success(playlists ?? []))
                    case .failure(let error):
                        single(.failure(error))
                    }
                })
            }
            return Disposables.create()
        }
        
    }
    
    //MARK: - Search
    
    public func search(with query: String) -> Observable<[SearchResult]> {
        return Observable<[SearchResult]>.create { observer -> Disposable in
            self.createRequest(with: URL(string: "\(Constants.baseAPIURL)/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { [weak self] baseRequest in
                debugPrint(baseRequest.url?.absoluteString ?? "none")
                self?.createTask(with: baseRequest, completion: { (result:Result<SearchResultResponse, Error>) in
                    var searchResults = [SearchResult]()
                    
                    switch result {
                    case .success(let queryResults):
                        searchResults.append(contentsOf: queryResults.tracks?.items.compactMap({SearchResult.track(model: $0)}) ?? [])
                        
                        searchResults.append(contentsOf: queryResults.albums?.items.compactMap({SearchResult.album(model: $0)}) ?? [])
                        
                        searchResults.append(contentsOf: queryResults.artists?.items.compactMap({SearchResult.artist(model: $0)}) ?? [])
                        
                        searchResults.append(contentsOf: queryResults.playlists?.items.compactMap({SearchResult.playlist(model: $0)}) ?? [])
                        observer.onNext(searchResults)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            }
            return Disposables.create()
        }
    }
    
    
    //MARK: - Profile -
    
    
    //MARK: - Profile -
    public func getCurrentUserProfile(completion: @escaping (Result<User, Error>)->Void) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/me"), type: .GET) { [weak self] baseRequest in
            
            self?.createTask(with: baseRequest, completion: {
                result in
                completion(result)
            })
        }
    }
    
    
    //MARK: - Browse -
    public func getRecommendedGenres(completion: @escaping(Result<RecommendedGenres, Error>) -> Void) {
        createRequest(with: URL(string: "\(Constants.baseAPIURL)/recommendations/available-genre-seeds"), type: .GET) { [weak self] baseRequest in
            self?.createTask(with: baseRequest, completion: { result in
                completion(result)
            })
        }
    }
    
    public func getRecommendations(genres: Set<String>) -> Single<Recommendation> {
        return Single.create { single in
            let seeds = genres.joined(separator: ",")
            self.createRequest(with: URL(string: "\(Constants.baseAPIURL)/recommendations?seed_genres=\(seeds)"), type: .GET) { [weak self] baseRequest in
                self?.createTask(with: baseRequest, completion: { (result: Result<Recommendation, Error>) in
                    switch result {
                    case .success(let recommendation):
                        single(.success(recommendation))
                    case .failure(let error):
                        single(.failure(error))
                    }
                })
            }
            return Disposables.create()
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
