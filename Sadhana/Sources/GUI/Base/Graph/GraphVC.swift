//
//  GraphVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 8/9/17.
//  Copyright © 2017 Alexander Koryttsev. All rights reserved.
//



import Crashlytics

import EasyPeasy

class GraphVC<VM:GraphVM>: BaseTableVC <VM> {
    
    var headerVisible = true {
        didSet {
            if oldValue != headerVisible {
                self.updateTitle()
            }
        }
    }
    
    var userNameHeight = CGFloat(0)

    init(_ viewModel: VM) {
        super.init(viewModel, style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Lifecycle
    override func viewDidLoad() {
        
        refreshControl = UIRefreshControl()

        super.viewDidLoad()

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.classString)
        tableView.register(GraphHeader.self, forHeaderFooterViewReuseIdentifier: GraphHeader.classString)

        if viewModel.shouldShowHeader {
            let favoriteButtonHeight = CGFloat(55)
            
            let header = UIView(frame:CGRect(x:0, y:0, width:ScreenWidth, height:ScreenWidth + favoriteButtonHeight))
            
            let avatarSize = header.bounds.size.width
            let avatarView = UIImageView(frame:CGRect(x:0, y:0, width: avatarSize, height: avatarSize))
            if let url = viewModel.info.avatarURL {
                avatarView.af_setImage(withURL:url, placeholderImage:#imageLiteral(resourceName: "default-avatar"), imageTransition:.crossDissolve(0.25))
            }
            else {
                avatarView.image = #imageLiteral(resourceName: "default-avatar")
            }
            
            let gradient = LinearGradientView()
            avatarView.addSubview(gradient)
            gradient.easy.layout([Left(), Bottom(), Right(), Height(108)])
            
            let userNameLabel = UILabel()
            userNameLabel.text = viewModel.info.userName
            userNameLabel.textColor = .white
            userNameLabel.textAlignment = .center
            userNameLabel.font = UIFont.systemFont(ofSize: 22)
            userNameLabel.sizeToFit()
            userNameHeight = 22 + userNameLabel.bounds.size.height + 22
            avatarView.addSubview(userNameLabel)
            userNameLabel.easy.layout([Left(10), Bottom(22), Right(10)])
            
            header.addSubview(avatarView)
            
            let favoriteButton = UIButton(type: .custom)
            favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(0, -14, 0, 14)
            
            favoriteButton.setImage(#imageLiteral(resourceName: "add-favorite-big"), for: .normal)
            favoriteButton.setTitle("favorites_add_profile".localized, for: .normal)
            favoriteButton.setTitleColor(.white, for: .normal)
            
            favoriteButton.setImage(#imageLiteral(resourceName: "remove-favorite-big"), for: .selected)
            favoriteButton.setTitle("favorites_remove_profile".localized, for: .selected)
            favoriteButton.setTitleColor(.sdTangerine, for: .selected)
            favoriteButton.setTitleColor(.sdSilver, for: .highlighted)
            favoriteButton.setTitleColor(.sdSilver, for: [.highlighted, .selected])
            
            favoriteButton.addTarget(self, action: #selector(GraphVC.toggleFavorite), for: .touchUpInside)
            update(favoriteButton: favoriteButton)
            
            header.addSubview(favoriteButton)
            favoriteButton.frame = CGRect(x:0, y: avatarSize, width:header.bounds.size.width, height:favoriteButtonHeight)
            
            UIView.performWithoutAnimation {
                self.tableView.tableHeaderView = header
                avatarView.setNeedsLayout()
                avatarView.layoutIfNeeded()
            }
            
            updateTitle()
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadData()
        self.tableView.reloadData()
        viewModel.refresh.onNext(())
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentView(withName: viewModel.info.userID == Main.service.currentUser!.ID ? "My Graph" : "Other Graph",
                               contentType: nil,
                               contentId: nil,
                               customAttributes: nil)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        refreshControl!.rx.controlEvent(.valueChanged).asDriver()
            .drive(viewModel.refresh).disposed(by: disposeBag)
        
        setUpDefaultActivityIndicator(with: viewModel.pageRunning.asDriver().map { running, _ -> Bool in
            return running
        })
        
        viewModel.firstPageRunning.drive(refreshControl!.rx.isRefreshing).disposed(by: disposeBag)
        
        viewModel.dataDidReload.asDriver(onErrorJustReturn: ()).drive(onNext:reloadData).disposed(by: disposeBag)
        
        viewModel.pageDidUpdate.asDriver(onErrorJustReturn: 0).drive(onNext: { [unowned self] (section) in
            if let paths = self.tableView.indexPathsForVisibleRows {
                for path in paths {
                    if path.section == section {
                        if let cell = self.tableView.cellForRow(at: path) {
                            self.setUp(cell, at: path)
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground).map { _ in }.bind(to: viewModel.refresh).disposed(by: disposeBag)
    }
    
    //MARK: - Actions
    
    @objc func toggleFavorite(_ sender: UIButton) {
        viewModel.toggleFavorite()
        update(favoriteButton: sender)
    }
    
    func update(favoriteButton: UIButton) {
        favoriteButton.isSelected = viewModel.favorite
        favoriteButton.backgroundColor = viewModel.favorite ? .white : .sdTangerine
    }
    
    func updateTitle() {
        if viewModel.shouldShowHeader {
            title = headerVisible ? "profile".localized : viewModel.info.userName
        }
    }

    //MARK: - Table Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(for: section)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(GraphHeader.self)) as! GraphHeader
        header.textLabel?.isHidden = true
        header.titleLabel.text = viewModel.title(for:section)
        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(EntryCell.self)) ?? EntryCell()) as! EntryCell
        setUp(cell, at: indexPath)
        return cell
    }

    func setUp(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as! EntryCell
        let (entry, date) = viewModel.entry(at: indexPath)
        if let entry = entry {
            cell.map(entry, maxRoundsCount:viewModel.maxCount(for: indexPath.section))
        }
        else {
            cell.clear(date)
        }
    }
    
    //MARK: Scroll Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel.shouldShowHeader {
            headerVisible = (tableView.contentOffset.y + TopInset)  < ScreenWidth
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if viewModel.shouldShowHeader {
            let difference = ScreenWidth - (targetContentOffset.pointee.y + TopInset)
            if difference > 0 && difference < userNameHeight {
                if difference < userNameHeight/2.0 || velocity.y > 0 { //Bottom
                    targetContentOffset.initialize(to: CGPoint(x:0, y:ScreenWidth - TopInset))
                }
                else { //Top
                    targetContentOffset.initialize(to: CGPoint(x:0, y:ScreenWidth - TopInset - userNameHeight))
                }
            }
        }
    }
}

class GraphHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier ?? NSStringFromClass(GraphHeader.self))
        backgroundView = BlurView()
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.sdBrownishGrey
        titleLabel.easy.layout(Center())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
