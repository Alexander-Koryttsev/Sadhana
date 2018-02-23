//
//  FavoriteGraphListVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//




typealias RowChange = (RowChangeType, IndexPath)

enum RowChangeType {
    case insert
    case update
    case delete
}

class FavoriteGraphListVM : GraphListVM {
    private unowned let router : OtherGraphListRouter

    let refresh = PublishSubject<Void>()
    let activityIndicator = ActivityIndicator()

    var change : Observable<RowChange> {
        return changeInternal.asObservable()
    }
    private let changeInternal = PublishSubject<RowChange>()

    private var favorites : NSOrderedSet {
        return Main.service.currentUser?.favorites ?? NSOrderedSet()
    }
    
    init(_ router:OtherGraphListRouter) {
        self.router = router
        super.init()

        refresh.flatMapLatest { [unowned self] _ -> Observable<Bool> in
            let signals = self.favorites.map({ (any) -> Observable<Bool> in
                 let user = any as! ManagedUser
                return Main.service.loadEntries(for: user)
                    .observeOn(MainScheduler.instance)
                    .do(onSuccess:{ [unowned self] _ in
                        self.changeInternal.onNext((.update, IndexPath(row: self.favorites.index(of: user), section: 0)))
                    })
                    .track(self.errors)
                    .asBoolObservable()
            })

            return Observable.merge(signals)
                    .track(self.activityIndicator)
        }   .subscribe()
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var numberOfSections: Int {
        return 1
    }
    
    override func numberOfRows(in section: Int) -> Int {
        return favorites.count
    }

    func user(at indexPath: IndexPath) -> ManagedUser {
        return favorites[indexPath.row] as! ManagedUser
    }

    func userAndEntry(at indexPath: IndexPath) -> (ManagedUser, Entry?) {
        let user = self.user(at: indexPath)
        return (user, Local.service.viewContext.fetchEntry(for: Date(), userID: user.ID))
    }
    
    override func select(_ indexPath: IndexPath) {
        router.showGraph(of: user(at: indexPath))
    }
    
    @available(iOS 11, *)
    override func trailingSwipeActionsConfiguration(forRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteUser = self.user(at: indexPath)
        
        let action = UIContextualAction(style: .normal, title: "Отписаться") { [weak self] (action, view, handler) in
            favoriteUser.removeFromFavorites()
            self?.changeInternal.onNext((.delete, indexPath))
            handler(true)
        }
       // action.image = #imageLiteral(resourceName: "remove-favorite-small")
        action.backgroundColor = .sdSilver
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }

    func move(_ sourceIndexPath: IndexPath, to targetIndexPath: IndexPath) {
        let favorite = user(at: sourceIndexPath)
        Main.service.currentUser!.removeFromFavorites(at:sourceIndexPath.row)
        Main.service.currentUser!.insertIntoFavorites(favorite, at: targetIndexPath.row)

    }
}
