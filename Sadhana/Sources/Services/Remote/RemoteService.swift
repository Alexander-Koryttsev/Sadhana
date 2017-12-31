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
import AlamofireImage

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
    case entryExists = "sadhana_entry_exists"
    case restForbidden = "rest_forbidden"
    case entryNotFound = "entry_not_found"
    case unknown
}

class RemoteService {
    private let clientID = "IXndKqmEoXPTwu46f7nmTcoJ2CfIS6"
    private let clientSecret = "1A4oOPOatd8j6EOaL3i9pblOUnqa6j"
    
    private var tokens = Tokens()
    struct Tokens {
        var access : String?
        var refresh : String?
        var type : String?
    }
    
    private var authorizationHeaders : [String : String]? {
        get {
            guard let tokenType = tokens.type, let accessToken = tokens.access else {
                return nil
            }
            return ["Authorization" : "\(tokenType) \(accessToken)"];
        }
    }
    private let acceptableStatusCodes:Array<Int>
    private let manager : Alamofire.SessionManager
    private let running = ActivityIndicator()
    
    init() {
        var codes = Array(200..<300)
        codes.append(contentsOf: (400..<500))
        acceptableStatusCodes = codes

        // Create the server trust policies
        #if DEV
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            Config.host: .disableEvaluation,
            ]
        #else
            let serverTrustPolicies = [String:ServerTrustPolicy]()
        #endif

        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let trustManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        manager = SessionManager(configuration: configuration, serverTrustPolicyManager: trustManager)

        UIImageView.af_sharedImageDownloader = ImageDownloader(sessionManager:SessionManager(configuration: configuration, serverTrustPolicyManager: trustManager))
        
        restoreTokensFromCache()
        remoteLog("host: \(Config.host)")

        _ = running.asDriver().drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
    }
    
    func restoreTokensFromCache() -> Void {
        guard let cachedTokens = Local.defaults.tokens else { return }
        map(tokens: cachedTokens)
    }
    
    func map(tokens: JSON) -> Void {
        //TODO: validate tokens
        self.tokens.access = tokens["access_token"] as? String
        self.tokens.refresh = tokens["refresh_token"] as? String
        self.tokens.type = tokens["token_type"] as? String
    }
    
    func mapAndCache(tokens: JSON) -> Void {
        map(tokens: tokens)
        Local.defaults.tokens = tokens
    }
    
    func refreshTokens() -> Completable {
        guard let tokenRefresh = tokens.refresh  else { return Completable.error(RemoteError.noRefreshToken) }
        return baseRequest(.post, Remote.URL.authToken.path, parameters:
            ["grant_type" : GrantType.refreshToken.rawValue,
             "refresh_token" : tokenRefresh,
             "client_id" : clientID,
             "client_secret" : clientSecret]).do(onNext: { [weak self] (json) in
                self?.mapAndCache(tokens: json)
             }).completable()
    }

    func login(name:String, password:String) -> Completable {

        return baseRequest(.post, Remote.URL.authToken.path, parameters:
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
            
            let request = self.manager.request("\(Remote.URL.prefix)/\(path)", method: method, parameters: parameters, encoding: JSONEncoding.default, headers: authorise ? self.authorizationHeaders : nil)
            
            remoteLog("\n\t\t\t\t\t--- \(method) \(path) ---\n\nHead: \(desc(request.request?.allHTTPHeaderFields))\n\nParamteters: \(desc(parameters))")
            request .validate(statusCode: self.acceptableStatusCodes)
                    .validate(contentType: ["application/json"])
                    .responseJSON(completionHandler: { (response) in
                remoteLog("\nResponse (\(path))\n\(response)\n")
                switch response.result {
                case .success(let value):

                    let statusCode = response.response!.statusCode
                    remoteLog("Status Code:\(statusCode)")

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

                        guard   let errorType = (result["error"] ?? result["code"]) as? String,
                                let errorDescription = (result["error_description"] ?? result["message"]) as? String
                        else {
                            observer(.error(RemoteError.invalidResponse))
                            return
                        }

                        let type = InvalidRequestType(rawValue: errorType) ?? .unknown
                        var error = RemoteError.invalidRequest(type:type, description:errorDescription)

                        switch type {
                            case .notLoggedIn, .restForbidden:
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
        }.track(running)
    }
    
    func apiRequest(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil) -> Single<JSON> {

            let request = baseRequest(method, "\(Remote.URL.api.path)/\(path)", parameters: parameters, authorise: true)
            
            return request.catchError { (handler: Error) -> Single<JSON> in
                let returningError = Single<JSON>.error(handler)
                guard let remoteError = handler as? RemoteError else { return returningError }
                
                switch remoteError {
                case .noTokens: return Single<JSON>.error(RemoteError.notLoggedIn)
                case .tokensExpired: return request.after(self.refreshTokens()).catchError({ (handler) -> Single<JSON> in
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
    func send(_ user: User) -> Completable {
        return apiRequest(.post, "options/\(user.ID)", parameters: user.json).completable()
    }

    func loadEntries(for userID:Int32, lastUpdatedDate:Date? = nil, month:Date? = nil) -> Single <[Entry]> {

        var parameters = [String: Any]()
        if let lastUpdatedDate = lastUpdatedDate {
            parameters["modified_since"] = lastUpdatedDate.remoteDateTimeString()
        }
        else {
            parameters["year"] = month?.year
            parameters["month"] = month?.month
        }

        return apiRequest(.post, "userSadhanaEntries/\(userID)", parameters:parameters).map({ (json) -> [JSON] in
            guard let entries = json["entries"] as? [JSON] else {
                throw RemoteError.invalidData
            }
            return entries
        }).map(array:RemoteEntry.self).cast([Entry].self)
    }

    func loadAllEntries(country:String = "all", city:String = "", searchString:String = "", page:Int = 0, pageSize:Int = 30) -> Single<AllEntriesResponse> {
        return apiRequest(.post, "allSadhanaEntries", parameters: ["country": country,
                                                                   "city": city,
                                                                   "search_term": searchString,
                                                                   "page_num": page,
                                                                   "items_per_page": pageSize]).map(object: AllEntriesResponse.self)
    }

    func send(_ entry: Entry) -> Single<Int32?> {
        let path = "sadhanaEntry/\(entry.userID)"

        return apiRequest(entry.ID == nil ? .post : .put, path, parameters: entry.json).catchError({ [unowned self] (error) -> PrimitiveSequence<SingleTrait, JSON> in
            
            switch error {
            case RemoteError.invalidRequest(let type, _):
                switch type {
                    case .entryNotFound:
                        var entryJson = entry.json
                        entryJson.removeValue(forKey: "entry_id")
                        return self.apiRequest(.post, path, parameters: entryJson)
                    case .entryExists:
                        let loadEntries = self.loadEntries(for: entry.userID, month: entry.date.trimmedDayAndTime)
                        let mapEntries = loadEntries.flatMap({ [unowned self] (entries) -> Single<JSON> in

                            let currentEntryFilter = entries.filter({ (filterEntry) -> Bool in
                                return filterEntry.date == entry.date
                            })

                            if let currentEntry = currentEntryFilter.first {
                                if currentEntry.dateUpdated > entry.dateUpdated {
                                    return Single.just(["entry_id": currentEntry.ID!])
                                }
                                var entryJson = entry.json
                                entryJson["entry_id"] = currentEntry.ID!
                                return self.apiRequest(.put, path, parameters: entryJson)
                            }

                            return Single.error(error)
                        })

                        return mapEntries

                    default: break
                }
                
                break

            default: break
            }
            
            return Single.error(error)
        })
            .map({ (json) -> Int32? in

            guard let jsonValue = json["entry_id"] else {
                throw RemoteError.invalidData
            }

            if jsonValue is Int32 {
                return jsonValue as? Int32
            }

            if jsonValue is String {
                return Int32(jsonValue as! String)!
            }

            if jsonValue is NSNull {
                return nil
            }

            throw RemoteError.invalidData
        })
    }
}

