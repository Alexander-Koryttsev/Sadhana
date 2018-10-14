//
//  RemoteService.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/25/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



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
    case invalidData
    case noTokens
    case userNotFound(Int32)
}

enum RemoteErrorKey : String, Error {
    case invalidGrant = "invalid_grant"
    case notLoggedIn = "json_not_logged_in"
    case entryExists = "sadhana_entry_exists"
    case restForbidden = "rest_forbidden"
    case entryNotFound = "entry_not_found"
    case userNotFound = "user_not_found"
    case emailExist = "existing_user_email"
}

struct Remote {
    static let service = RemoteService()

    enum URL : String {
        static let prefix = "https://\(Config.host)/"

        case api = "vs-api/v2/sadhana"
        case authToken = "?oauth=token"
        case defaultAvatar = "wp-content/themes/socialize-child/img/default_avatar.png"

        var fullString : String {
            get {
                return "\(URL.prefix)\(rawValue)"
            }
        }

        var fullURL : Foundation.URL {
            return Foundation.URL(string:fullString)!
        }

        var relativeString : String {
            return rawValue
        }
    }
}

class SessionDelegate : NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

class RemoteService {
    let networkDidAppear : Observable<Void>

    private let clientID = "IXndKqmEoXPTwu46f7nmTcoJ2CfIS6"
    private let clientSecret = "1A4oOPOatd8j6EOaL3i9pblOUnqa6j"
    
    private var tokens : Tokens?
    struct Tokens {
        let access : String
        let refresh : String
        let type : String
    }
    
    private var authorizationHeaders : [String : String]? {
        get {
            guard let tokens = tokens else {
                return nil
            }
            return ["Authorization" : "\(tokens.type) \(tokens.access)"];
        }
    }
    private let acceptableStatusCodes:Array<Int>
    private let manager : Alamofire.SessionManager
    private let running = ActivityIndicator()
    private let session = URLSession(configuration: .default, delegate: SessionDelegate(), delegateQueue: nil)
    private let reachability : NetworkReachabilityManager
    private var pendingAuthorizedRequests = [ConnectableObservable<JSON>]()
    
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

        _ = running.asDriver().drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)

        let reachability = NetworkReachabilityManager(host: Config.host)!
        networkDidAppear = Observable<Void>.create {(observer) -> Disposable in
            reachability.listener = { (status) in
                if case NetworkReachabilityManager.NetworkReachabilityStatus.reachable(_) = status {
                    observer.onNext(())
                }
            }
            reachability.startListening()

            return Disposables.create {
                reachability.stopListening()
            }
        }.share(replay: 0)
        self.reachability = reachability

        restoreTokensFromCache()
        remoteLog("host: \(Config.host)")
    }
    
    func restoreTokensFromCache() -> Void {
        guard let cachedTokens = Local.defaults.tokens else { return }
        map(tokens: cachedTokens)
    }
    
    func map(tokens: JSON) {
        if  let access = tokens["access_token"] as? String,
            let refresh = tokens["refresh_token"] as? String,
            let type = tokens["token_type"] as? String {
            self.tokens = Tokens(access: access, refresh: refresh, type: type)
        }
        else {
            self.tokens = nil
        }
    }
    
    func mapAndCache(tokens: JSON) -> Void {
        map(tokens: tokens)
        Local.defaults.tokens = tokens
    }

    func clearTokens() {
        self.tokens = nil
        Local.defaults.tokens = nil
    }
    
    func refreshTokens() -> Observable<Bool> {
        guard let tokens = self.tokens else { return relogin() }
        let request = baseRequest(.post, Remote.URL.authToken.relativeString, parameters:
            ["grant_type" : GrantType.refreshToken.rawValue,
             "refresh_token" : tokens.refresh,
             "client_id" : clientID,
             "client_secret" : clientSecret]).map { (json) -> Bool in
                self.mapAndCache(tokens: json)
                return true
        }

        return request.catchError({ [unowned self] (error) -> Observable<Bool> in
                let returningError = Observable<Bool>.error(error)
                switch error {
                case RemoteErrorKey.invalidGrant:
                    self.clearTokens()
                    return self.relogin()
                default: return returningError
                }
             })
    }

    func relogin() -> Observable<Bool> {
        guard   let email = Local.defaults.userEmail,
                let password = Local.defaults.userPassword else {
                return Observable<Bool>.error(RemoteErrorKey.notLoggedIn)
        }

        return self.login(name: email, password: password).do(onError: { (error) in
            switch error {
            case RemoteErrorKey.invalidGrant: Local.defaults.userPassword = nil; break
            default: break
            }
        })
    }

    var hasCachedCredentials : Bool {
        return Local.defaults.userEmail != nil && Local.defaults.userPassword != nil
    }

    func login(name:String, password:String) -> Observable<Bool> {
        return baseRequest(.post, Remote.URL.authToken.relativeString, parameters:
            ["grant_type" : GrantType.password.rawValue,
             "client_id" : clientID,
             "client_secret" : clientSecret,
             "username" : name,
             "password" : password]).map({ [unowned self] (json) -> Bool in
                self.mapAndCache(tokens: json)
                return true
             })
    }
    
    func baseRequest(_ method: Alamofire.HTTPMethod,
                     _ path: String,
                     parameters: [String: Any]? = nil,
                     authorise: Bool = false,
                     shouldLog: Bool = true) -> Observable<JSON> {
        return Observable<JSON>.create { [unowned self] (observer) -> Disposable in
            if authorise && self.tokens == nil {
                observer.onError(RemoteError.noTokens)
                return Disposables.create {} 
            }
            
            let request = self.manager.request("\(Remote.URL.prefix)\(path)", method: method, parameters: parameters, encoding: JSONEncoding.default, headers: authorise ? self.authorizationHeaders : nil)
            
            if shouldLog {
                remoteLog("\n\t\t\t\t\t--- \(method) \(path) ---\n\nHead: \(desc(request.request?.allHTTPHeaderFields))\n\nParamteters: \(desc(parameters))")
            }
            request .validate(statusCode: self.acceptableStatusCodes)
                    .validate(contentType: ["application/json"])
                    .responseJSON(completionHandler: { (response) in
                        if shouldLog {
                            remoteLog("\nResponse (\(path))\n\(response)\n")
                        }
                switch response.result {
                case .success(let value):
                    let statusCode = response.response!.statusCode
                    if shouldLog {
                        remoteLog("Status Code:\(statusCode)")
                    }

                    var result:JSON

                    if let resultArray = value as? [JSON] {
                        result = resultArray.first!
                    }
                    else if let resultObject = value as? JSON {
                        result = resultObject
                    }
                    else {
                        observer.onError(RemoteError.responseBodyIsNotJSON)
                        return
                    }

                    //Additional Validation
                    guard (200..<300).contains(statusCode) else {
                        //TODO: test in postman when tokens are not valid (for example login, check tokens,logout, check tokens)

                        guard   let errorKeyRawValue = (result["error"] ?? result["code"]) as? String,
                                let errorDescription = (result["error_description"] ?? result["message"]) as? String
                        else {
                            observer.onError(RemoteError.invalidResponse)
                            return
                        }

                        var error: Error
                        if let errorKey = RemoteErrorKey(rawValue: errorKeyRawValue) {
                            if errorKey == RemoteErrorKey.userNotFound,
                                let stringID = errorDescription.components(separatedBy: " ").last,
                                let ID = Int32(stringID) {
                                error = RemoteError.userNotFound(ID)
                            }
                            else {
                                error = errorKey
                            }
                        }
                        else {
                            error = GeneralError.message(errorDescription)
                        }
                        observer.onError(error)
                        return
                    }
                    observer.onNext(result)
                    observer.onCompleted()
                    return
                    
                case .failure(let error):
                    observer.onError(error)
                    return
                }
            })
            return Disposables.create {
                request.cancel()
            }
        }.track(running)
    }
    
    func apiRequest(_ method: Alamofire.HTTPMethod,
                    _ path: String,
                    parameters: [String: Any]? = nil,
                    shouldLog: Bool = true) -> Observable<JSON> {
        return baseRequest(method, "\(Remote.URL.api.relativeString)/\(path)",
                          parameters: parameters,
                          shouldLog: shouldLog)
    }

    func authorizedApiRequest(_ method: Alamofire.HTTPMethod,
                              _ path: String,
                              parameters: [String: Any]? = nil,
                              shouldLog: Bool = true) -> Observable<JSON> {
        let request = baseRequest(method, "\(Remote.URL.api.relativeString)/\(path)",
                                 parameters: parameters,
                                 authorise: true,
                                 shouldLog: shouldLog)

        let requestFinal = request.catchError { [unowned self] (error: Error) -> Observable<JSON> in
            switch error {
            case RemoteErrorKey.invalidGrant,
                 RemoteErrorKey.notLoggedIn,
                 RemoteErrorKey.restForbidden,
                 RemoteError.noTokens:
                return self.refreshTokens().flatMap{_ in request}
            default: return Observable<JSON>.error(error)
            }
        }

        return add(authorizedApiRequest: requestFinal)
    }

    func add(authorizedApiRequest request:Observable<JSON>) -> ConnectableObservable<JSON> {
        let connectable = request.do(onError: { [unowned self] (_) in
            self.pendingAuthorizedRequests.removeFirst()
            self.connectRequest()
            }, onCompleted: { [unowned self] in
                self.pendingAuthorizedRequests.removeFirst()
                self.connectRequest()
        }).publish()

        pendingAuthorizedRequests.append(connectable)
        if pendingAuthorizedRequests.count == 1 {
            connectRequest()
        }

        return connectable
    }

    func connectRequest() {
        if let first = pendingAuthorizedRequests.first {
            _ = first.connect()
        }
    }

    // MARK: API Methods
    func loadCurrentUser() -> Observable<User> {
        return authorizedApiRequest(.get, "me").map(object: RemoteUser.self).cast(User.self)
    }
    
    @discardableResult
    func send(_ user: User) -> Observable<Bool> {
        return authorizedApiRequest(.post, "options/\(user.ID)", parameters: user.json).mapTrue()
    }

    func loadEntries(for userID:Int32, lastUpdatedDate:Date? = nil, month:LocalDate? = nil) -> Observable <[Entry]> {

        var parameters = [String: Any]()
        if let lastUpdatedDate = lastUpdatedDate {
            parameters["modified_since"] = lastUpdatedDate.remoteDateTimeString
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

    func loadAllEntries(country:String = "all", city:String = "", searchString:String = "", page:Int = 0, pageSize:Int = 30) -> Observable<AllEntriesResponse> {
        return apiRequest(.post, "allSadhanaEntries", parameters: ["country": country,
                                                                   "city": city,
                                                                   "search_term": searchString,
                                                                   "page_num": page,
                                                                   "items_per_page": pageSize],
                          shouldLog: false).map(object: AllEntriesResponse.self)
    }

    func send(_ entry: Entry) -> Observable<Int32?> {
        let path = "sadhanaEntry/\(entry.userID)"

        return authorizedApiRequest(entry.ID == nil ? .post : .put, path, parameters: entry.json).catchError({ [unowned self] (error) -> Observable<JSON> in
            switch error {
                case RemoteErrorKey.entryNotFound:
                    var entryJson = entry.json
                    entryJson.removeValue(forKey: "entry_id")
                    return self.apiRequest(.post, path, parameters: entryJson)
                case RemoteErrorKey.entryExists:
                    let loadEntries = self.loadEntries(for: entry.userID, month: entry.localDate)
                    let mapEntries = loadEntries.flatMap({ [unowned self] (remoteEntries) -> Observable<JSON> in

                        let currentRemoteEntryFilter = remoteEntries.filter({ (filterEntry) -> Bool in
                            return filterEntry.date == entry.date
                        })

                        if let remoteEntry = currentRemoteEntryFilter.first {
                            if remoteEntry.dateUpdated > entry.dateUpdated {
                                return Observable.just(["entry_id": remoteEntry.ID!])
                            }
                            var entryJson = entry.json
                            entryJson["entry_id"] = remoteEntry.ID!
                            return self.apiRequest(.put, path, parameters: entryJson)
                        }

                        return Observable.error(error)
                    })

                    return mapEntries

                default: break
            }
            
            return Observable.error(error)
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

    func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> Observable<JSON> {
            return Observable<JSON>.create { [unowned self] (observer) -> Disposable in

                let request = self.manager.request(url, method: method, parameters:parameters, encoding: encoding, headers:headers)

                request.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? JSON {
                            observer.onNext(json)
                            observer.onCompleted()
                        }
                        else {
                            observer.onError(RemoteError.invalidData)
                        }
                        break

                    case .failure(let error):
                        observer.onError(error)
                        break
                    }
                })

                return Disposables.create {
                    request.cancel()
                }
            }
    }

    func loadCountries() -> Observable<[Country]> {
        return request("https://vaishnavaseva.net/vs-api/v2/sadhana/countries",
                       method: HTTPMethod.get,
                       parameters: ["v": 5.71,
                                    "need_all": 1,
                                    "count":1000,
                                    "lang":Locale.current.languageCode!])
            .map { json in
                if  let root = json["response"] as? NSDictionary,
                    let items = root["items"] as? [NSDictionary] {

                    return try! items.map { try Country(map: Mapper(JSON: $0))
                    }
                }
                else {
                    throw RemoteError.invalidData
                }
        }
    }

    func loadCities(countryID: Int32, query: String? = nil) -> Observable<[City]> {
        return request("https://vaishnavaseva.net/vs-api/v2/sadhana/cities",
                       method: HTTPMethod.get,
                       parameters: ["country_id": countryID,
                                    "v": 5.69,
                                    "need_all": 0,
                                    "count":100,
                                    "lang":Locale.current.languageCode!,
                                    "q":query ?? ""])
            .map { json in
                if  let root = json["response"] as? NSDictionary,
                    let items = root["items"] as? [NSDictionary] {
                    
                    return try! items.map { try City(map: Mapper(JSON: $0))
                    }
                }
                else {
                    throw RemoteError.invalidData
                }
            }
    }

    func register(_ registration: Registration) -> Observable<Int32> {
        return baseRequest(.post, "\(Remote.URL.api.relativeString)/registration", parameters: registration.json).map({ (json) -> Int32 in
            return try Int32.create(json["user_id"])
        });
    }

    func initialize(_ userID: Int32) -> Observable<Bool> {
        return authorizedApiRequest(.post, "initialize/\(userID)").mapTrue()
    }

    func loadProfile(_ userID: Int32) -> Observable<Profile> {
        return apiRequest(.get, "userProfile/\(userID)").map(object: RemoteProfile.self).cast(Profile.self)
    }

    func send(profile: Profile) -> Observable<Bool> {
        return authorizedApiRequest(.post, "userProfile/\(profile.ID)", parameters: profile.profileJson).mapTrue()
    }
}

extension Int32 {
    static func create(_ value: Any?) throws -> Int32 {
        if let int32 = value as? Int32 {
            return Int32(int32)
        }
        else if let string = value as? String {
            guard let int32 = Int32(string) else {
                throw RemoteError.invalidData
            }
            return int32
        }
        else {
            throw RemoteError.invalidData
        }
    }
}


extension NSURLRequest {
    #if DEBUG
    static func allowsAnyHTTPSCertificate(forHost host: String) -> Bool {
        return true
    }
    #endif
}

