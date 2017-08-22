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
    let select = PublishSubject<IndexPath>()
    let pageDidUpdate = PublishSubject<Int>()
    let dataDidReload = PublishSubject<Void>()
    private var lastResponse : AllEntriesResponse?
    private var pages = [Int : [RemoteEntry]]()
    var pagesCount : Int {
        get {
            return lastResponse != nil ? Int(ceil(Float(lastResponse!.total)/Float(lastResponse!.pageSize))) : 0
        }
    }

    private let router : OtherGraphListRouter

    init(_ router:OtherGraphListRouter) {
        self.router = router
        firstPageRunning = pageRunning.asDriver(for:0)
        super.init()

        refresh.subscribe(onNext: { [unowned self] () in
            return Remote.service.loadAllEntries()
                .track(self.pageRunning, index:0)
                .track(self.errors)
                .subscribe(onSuccess: { [unowned self] (response) in
                    self.pages.removeAll()
                    self.pages[response.page] = response.entries
                    self.lastResponse = response
                    self.dataDidReload.onNext()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }

    func entriesCount(in section:Int) -> Int {
        guard let response = lastResponse else { return 0 }

        if let page = pages[section],
               page.count > 0 {
            return page.count
        }

        if section == (pagesCount - 1) {
            return pagesCount * response.pageSize - response.total
        }

        return response.pageSize
    }

    func load(page:Int) -> Single<AllEntriesResponse> {
        return Remote.service.loadAllEntries(page:page).do(onNext: {[unowned self] (response) in
            self.pages[response.page] = response.entries
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

            if cachedPage(at: nextPageIndex).count == 0,
                !self.pageRunning.has(index: nextPageIndex) {
                load(page: nextPageIndex)
                    .subscribeOn(MainScheduler.instance)
                    .subscribe(onSuccess: { [unowned self] (_) in
                        self.pageDidUpdate.onNext(nextPageIndex)
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
