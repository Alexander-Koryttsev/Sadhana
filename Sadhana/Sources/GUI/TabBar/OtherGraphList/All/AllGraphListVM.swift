//
//  AllGraphListVM.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/21/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class AllGraphListVM : GraphListVM {
    let firstPageRunning : Driver<Bool>
    let pageRunning = IndexedActivityIndicator()
    let refresh = PublishSubject<Void>()
    let refreshDriver : Driver<Void>
    let search = Variable("")
    let select = PublishSubject<IndexPath>()
    let pageDidUpdate = PublishSubject<Int>()
    let dataDidReload = PublishSubject<Void>()
    private var lastResponse : AllEntriesResponse?
    private var pages = [Int : [RemoteEntry]]()
    private var loadingPages = IndexSet()
    var pagesCount : Int {
        get {
            return lastResponse != nil ? Int(ceil(Float(lastResponse!.total)/Float(lastResponse!.pageSize))) : 0
        }
    }

    private let router : OtherGraphListRouter

    init(_ router:OtherGraphListRouter) {
        self.router = router
        firstPageRunning = pageRunning.asDriver(for:0)
        refreshDriver = refresh.asDriver(onErrorJustReturn: ())
        super.init()

        let combined = Driver.combineLatest(refreshDriver, search.asDriver().debounce(0.5).skip(1)) { _,_ in }
        combined.drive(onNext: { [unowned self] in
            self.load(page: 0)
                .subscribe(onSuccess: { [unowned self] (response) in
                    self.pages.removeAll()
                    self.pages[response.page] = response.entries
                    self.dataDidReload.onNext()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        select.subscribe(onNext:{ [unowned self] (indexPath) in
            if let entry = self.entry(at: indexPath) {
                router.showGraphOfUser(with: entry.userID, name: entry.userName)
            }
        }).disposed(by: disposeBag)
    }

    func entriesCount(in section:Int) -> Int {
        guard let response = lastResponse else { return 0 }

        if let page = pages[section],
               page.count > 0 {
            return page.count
        }

        if section == (pagesCount - 1) {
            return response.total - (pagesCount - 1) * response.pageSize
        }

        return response.pageSize
    }

    func load(page:Int) -> Single<AllEntriesResponse> {
        return Remote.service.loadAllEntries(searchString:search.value, page:page).do(onNext: {[unowned self] (response) in
            self.lastResponse = response
        })  .track(pageRunning, index:page)
            .track(self.errors)
    }

    func cachedPage(at index:Int) -> [RemoteEntry] {
        return pages[index] ?? []
    }

    func entry(at indexPath:IndexPath) -> RemoteEntry? {
        guard let response = lastResponse else { return nil }

        let pageIndex = indexPath.section
        if  indexPath.row > (response.pageSize - 15),
            pageIndex < (pagesCount - 1) {
            let nextPageIndex = pageIndex + 1

            if cachedPage(at: nextPageIndex).count == 0 &&
                !self.pageRunning.has(index: nextPageIndex) &&
                !self.loadingPages.contains(nextPageIndex) {
                self.loadingPages.insert(nextPageIndex)
                
                load(page: nextPageIndex)
                    .subscribeOn(MainScheduler.instance)
                    .subscribe(onSuccess: { [unowned self] (newResponse) in
                        self.pages[newResponse.page] = newResponse.entries
                        self.pageDidUpdate.onNext(newResponse.page)
                        self.loadingPages.remove(newResponse.page)
                    }).disposed(by: disposeBag)
            }
        }

        let page = cachedPage(at:pageIndex)

        return page.count > 0 ? page[indexPath.row] : nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
