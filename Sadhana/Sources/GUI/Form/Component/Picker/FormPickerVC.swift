//
//  FormPickerVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 1/5/18.
//  Copyright © 2018 Alexander Koryttsev. All rights reserved.
//


import EasyPeasy

class FormPickerVC: BaseTableVC<FormPickerVM> {

    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchContainer = UIView(frame:CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:46))
        searchContainer.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.easy.layout([
            Left(2),
            Bottom(),
            Right(2),
            Top(iOS(11) ? 10 : 2)
            ])
        searchContainer.sizeToFit()

        UIView.performWithoutAnimation {
            tableView.tableHeaderView = searchContainer
            searchContainer.setNeedsLayout()
            searchContainer.layoutIfNeeded()
        }
        tableView.keyboardDismissMode = .interactive

        clearsSelectionOnViewWillAppear = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = searchBar.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Remote.service.networkDidAppear.bind(to: viewModel.refresh).disposed(by: viewModel.disappearBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func bindViewModel() {
        super.bindViewModel()

        refreshControl = UIRefreshControl()
        refreshControl!.rx.controlEvent(.valueChanged).bind(to: viewModel.refresh).disposed(by: disposeBag)

        setUpDefaultActivityIndicator(with: viewModel.activity.asDriver())

        searchBar.rx.textRequired.bind(to: viewModel.search).disposed(by: disposeBag)

        tableView.register(SubtitledCell.self, forCellReuseIdentifier: "Cell")
        viewModel.dataDidReload
            .do(onNext:{ [unowned self] _ in self.refreshControl?.endRefreshing() })
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { (index, item: Titled, cell) in
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = item.subtitle
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            }.disposed(by: disposeBag)

        tableView.rx.itemSelected.bind(to:viewModel.select).disposed(by: disposeBag)

        title = viewModel.title
        viewModel.refresh.onNext(())
    }
}

class SubtitledCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
