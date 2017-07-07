//
//  RemoteService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/25/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import Mapper

enum GrantType : String {
    case password = "password"
    case refreshToken = "refresh_token"
}

enum RemoteError : Error {
    case noRefreshToken
    case cantCast(value:Any, toType:Any.Type)
    case noData
    case invalidData
    case notLoggedIn
    case noTokens
    case tokensExpired
    case authorisationRequired
    case unacceptableResponce(type:Any.Type)
}

enum URLStatusCode : Int {
    case badRequest = 400
    case notLoggedIn = 401
}

struct URLs {
    static let base = "https://vaishnavaseva.net"
    static let api = "vs-api/v1/sadhana"
    static let authToken = "?oauth=token"
    static let default_avatar = "wp-content/themes/salient-child/img/default_avatar.gif"
}

struct UserDefaultsKey {
    static let prefix = "RemoteService"
    static let tokens = "\(prefix)Tokens"
}

class RemoteService {
    static let shared = RemoteService()
    let clientID = "IXndKqmEoXPTwu46f7nmTcoJ2CfIS6"
    let clientSecret = "1A4oOPOatd8j6EOaL3i9pblOUnqa6j"
    
    var tokens = Tokens()
    struct Tokens {
        var access : String?
        var refresh : String?
        var type : String?
    }
    
    var authorizationHeaders : [String : String]? {
        get {
            guard let tokenType = tokens.type, let accessToken = tokens.access else {
                return nil
            }
            return ["Authorization" : "\(tokenType) \(accessToken)"];
        }
    }
    
    init() {
        self.restoreTokensFromCache()
    }
    
    
    func restoreTokensFromCache() -> Void {
        guard let cachedTokens = UserDefaults.standard.object(forKey: UserDefaultsKey.tokens) as? JSON else { return }
        map(tokens: cachedTokens)
    }
    
    func cache(tokens: JSON) -> Void {
        UserDefaults.standard.set(tokens, forKey: UserDefaultsKey.tokens)
    }
    
    func map(tokens: JSON) -> Void {
        //TODO: validate tokens
        self.tokens.access = tokens["access_token"] as? String
        self.tokens.refresh = tokens["refresh_token"] as? String
        self.tokens.type = tokens["token_type"] as? String
    }
    
    func mapAndCache(tokens: JSON) -> Void {
        map(tokens: tokens)
        cache(tokens: tokens)
    }
    
    func refreshTokens() -> Completable {
        guard let tokenRefresh = tokens.refresh  else { return Completable.error(RemoteError.noRefreshToken) }
        return baseRequest(.post, URLs.authToken, parameters:
            ["grant_type" : GrantType.refreshToken.rawValue,
             "refresh_token" : tokenRefresh,
             "client_id" : clientID,
             "client_secret" : clientSecret]).do(onNext: { [weak self] (json) in
                self?.mapAndCache(tokens: json)
             }).completable()
    }

    func login(name: String, password: String) -> Completable {
        return baseRequest(.post, URLs.authToken, parameters:
            ["grant_type" : GrantType.password.rawValue,
             "client_id" : clientID,
             "client_secret" : clientSecret,
             "username" : name,
             "password" : password]).map({ [weak self] (json) -> Bool in
                self?.mapAndCache(tokens: json)
                return true
             }).completable()
    }
    
    func loadCurrentUser() -> Single <User> {
        return apiRequest(.get, "me", responseType:RemoteUser.self, castTo:User.self)
    }
    
    @discardableResult
    func send(user: User & JSONConvertible) -> Completable {
        
        print(desc(user.json()))
        
        return Completable.empty()
    }
    
    func baseRequest(_ method: Alamofire.HTTPMethod,
                     _ path: String,
                     parameters: [String: Any]? = nil,
                     authorise: Bool = false) -> Single<JSON> {
        return baseRequest(method, path, parameters: parameters, authorise: authorise, responseType: JSON.self)
    }
    
    func baseRequest<T>(_ method: Alamofire.HTTPMethod,
                     _ path: String,
                     parameters: [String: Any]? = nil,
                     authorise: Bool = false,
                     responseType: T.Type) -> Single<T> {
        return Single<T>.create { [weak self] (observer) -> Disposable in
            
            if authorise == true && self?.tokens.access == nil {
                observer(.error(RemoteError.noTokens))
                return Disposables.create {} 
            }
            
            let request = Alamofire.request("\(URLs.base)/\(path)", method: method, parameters: parameters, encoding: URLEncoding.default, headers: authorise ? self?.authorizationHeaders : nil)
            
            print("\n\t\t\t\t\t--- \(method) \(path) ---\n\nHead: \(desc(request.request?.allHTTPHeaderFields))\n\nParamteters: \(desc(parameters))")
            
            request.validate().responseJSON(completionHandler: { (response) in
                print("\nResponse\n\(response)\n")
                switch response.result {
                case .success(let value):
                    
                    guard let result = value as? T else {
                        observer(.error(RemoteError.cantCast(value: value, toType: T.self)))
                        return
                    }
                    observer(.success(result))
                    
                case .failure(let error):
                    
                    guard let statusCode = response.response?.statusCode else {
                        observer(.error(error))
                        return
                    }
                    
                    if(400..<500).contains(statusCode) {
                        //TODO: test in postman when tokens are not valid (for example login, check tokens,logout, check tokens)
                        observer(.error(authorise ? RemoteError.tokensExpired : RemoteError.authorisationRequired))
                        return
                    }
                    
                    observer(.error(error))
                }
            })
            return Disposables.create {}
        }
    }
    
    func apiRequest<T:Mappable, T2>(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil,
                    responseType: T.Type,
                    castTo: T2.Type) -> Single<T2> {
        return apiRequest(method, path, parameters: parameters, responseType: JSON.self).asObservable().map(object:responseType).cast(castTo).asSingle()
    }
    
    func apiRequest<T:Mappable, T2>(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil,
                    responseArrayElementType: T.Type,
                    castTo: T2.Type) -> Single<[T2]> {
        return apiRequest(method, path, parameters: parameters, responseType: [JSON].self).asObservable().map(array:responseArrayElementType).cast(array:castTo).asSingle()
    }
    
    func apiRequest<T>(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil,
                    responseType: T.Type)
        -> Single<T> {

            let request = baseRequest(method, "\(URLs.api)/\(path)", parameters: parameters, authorise: true, responseType:T.self)
            
            return request.catchError { (handler: Error) -> Single<T> in
                let returningError = Single<T>.error(handler)
                guard let remoteError = handler as? RemoteError else { return returningError }
                
                switch remoteError {
                case .noTokens: return Single<T>.error(RemoteError.notLoggedIn)
                case .tokensExpired: return request.asObservable().after(self.refreshTokens()).asSingle().catchError({ (handler) -> PrimitiveSequence<SingleTrait, T> in
                    let returningError = Single<T>.error(handler)
                    guard let remoteError = handler as? RemoteError else { return returningError }
                    switch remoteError {
                        case .tokensExpired: return Single<T>.error(RemoteError.notLoggedIn)
                        default: return returningError
                    }
                    
                })
                    default: return returningError
                }
            }
            
    }
}
