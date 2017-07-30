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

//TODO: cache sending requests

enum GrantType : String {
    case password = "password"
    case refreshToken = "refresh_token"
}

enum RemoteError : Error {
    case invalidResponse
    case responseBodyIsNotJSON
    case noRefreshToken
    case invalidData
    case noTokens
    case notLoggedIn
    case tokensExpired
    case authorisationRequired
    case invalidRequest(type:InvalidRequestType, description:String)
}

enum InvalidRequestType : String {
    case invalidGrant = "invalid_grant"
    case notLoggedIn = "json_not_logged_in"
    case unknown
}

struct URLs {
    static let base = "https://vaishnavaseva.net"
    static let api = "vs-api/v2/sadhana"
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
    let acceptableStatusCodes:Array<Int>
    
    init() {
        var codes = Array(200..<300)
        codes.append(contentsOf: (400..<500))
        acceptableStatusCodes = codes
        restoreTokensFromCache()
        tokens.access = "111"
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

    func login(name:String, password:String) -> Completable {

        return baseRequest(.post, URLs.authToken, parameters:
            ["grant_type" : GrantType.password.rawValue,
             "client_id" : clientID,
             "client_secret" : clientSecret,
             "username" : name,
             "password" : password]).do(onNext: { [weak self] (json) in
                self?.mapAndCache(tokens: json)
             }).completable()
    }
    
    func baseRequest(_ method: Alamofire.HTTPMethod,
                     _ path: String,
                     parameters: [String: Any]? = nil,
                     authorise: Bool = false) -> Single<JSON> {
        
        return Single<JSON>.create { [unowned self] (observer) -> Disposable in
            
            if authorise == true && self.tokens.access == nil {
                observer(.error(RemoteError.noTokens))
                return Disposables.create {} 
            }
            
            let request = Alamofire.request("\(URLs.base)/\(path)", method: method, parameters: parameters, encoding: JSONEncoding.default, headers: authorise ? self.authorizationHeaders : nil)
            
            print("\n\t\t\t\t\t--- \(method) \(path) ---\n\nHead: \(desc(request.request?.allHTTPHeaderFields))\n\nParamteters: \(desc(parameters))")
            request .validate(statusCode: self.acceptableStatusCodes)
                    .validate(contentType: ["application/json"])
                    .responseJSON(completionHandler: { (response) in
                print("\nResponse\n\(response)\n")
                switch response.result {
                case .success(let value):

                    let statusCode = response.response!.statusCode
                    print("Status Code:\(statusCode)")

                    var result:JSON

                    if let resultArray = value as? [JSON] {
                        result = resultArray.first!
                    }
                    else if let resultObject = value as? JSON {
                        result = resultObject
                    }
                    else {
                        observer(.error(RemoteError.responseBodyIsNotJSON))
                        return
                    }

                    //Additional Validation
                    guard (200..<300).contains(statusCode) else {

                        //TODO: test in postman when tokens are not valid (for example login, check tokens,logout, check tokens)
                        var error = RemoteError.invalidResponse
                        var type = InvalidRequestType.unknown

                            if  let errorType = (result["error"] ?? result["code"]) as? String,
                                let errorDescription = (result["error_description"] ?? result["message"]) as? String,
                                let typeLet = InvalidRequestType(rawValue: errorType) {
                                    type = typeLet
                                    error = RemoteError.invalidRequest(type:type, description:errorDescription)
                            }

                            switch type {
                                case .notLoggedIn, .unknown:
                                    error = authorise ? RemoteError.tokensExpired : RemoteError.authorisationRequired
                                break
                                default: break
                            }

                            observer(.error(error))
                            return
                    }

                    observer(.success(result))
                    
                case .failure(let error):
                    observer(.error(error))
                }
            })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func apiRequest(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil) -> Single<JSON> {

            let request = baseRequest(method, "\(URLs.api)/\(path)", parameters: parameters, authorise: true)
            
            return request.catchError { (handler: Error) -> Single<JSON> in
                let returningError = Single<JSON>.error(handler)
                guard let remoteError = handler as? RemoteError else { return returningError }
                
                switch remoteError {
                case .noTokens: return Single<JSON>.error(RemoteError.notLoggedIn)
                case .tokensExpired: return request.after(self.refreshTokens()).catchError({ (handler) -> PrimitiveSequence<SingleTrait, JSON> in
                    let returningError = Single<JSON>.error(handler)
                    guard let remoteError = handler as? RemoteError else { return returningError }
                    switch remoteError {
                        case .tokensExpired: return Single<JSON>.error(RemoteError.notLoggedIn)
                        default: return returningError
                    }
                })
                    default: return returningError
                }
            }
            
    }
    // MARK: API Methods
    func loadCurrentUser() -> Single <User> {
        return apiRequest(.get, "me").map(object: RemoteUser.self).cast(User.self)
    }
    
    @discardableResult
    func send(_ user: User & JSONConvertible) -> Completable {
        return apiRequest(.post, "options/\(user.ID)", parameters: user.json()).completable()
    }
    
    func loadSadhanaEntries(userID:Int32, year:Int, month:Int) -> Single <[Entry]> {
        return apiRequest(.post, "userSadhanaEntries/\(userID)", parameters:["year": year, "month": month]).map({ (json) -> [JSON] in
            guard let entries = json["entries"] as? [JSON] else {
                throw RemoteError.invalidData
            }
            return entries
        }).map(array:RemoteEntry.self).cast([Entry].self)
    }
    
    func send(_ entry: Entry & JSONConvertible) -> Single<Int32> {
        let path = "sadhanaEntry/\(entry.userID)"
        
        return apiRequest(entry.ID != nil ? .put : .post, path, parameters: entry.json()).map({ (json) -> Int32 in

            guard let jsonValue = json["entry_id"] else {
                throw RemoteError.invalidData
            }

            if jsonValue is Int32 {
                return jsonValue as! Int32
            }

            if jsonValue is String {
                return Int32(jsonValue as! String)!
            }

            throw RemoteError.invalidData
        })
    }
}
