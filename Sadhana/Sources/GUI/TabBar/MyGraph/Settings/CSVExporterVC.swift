//
//  CSVExporterVC.swift
//  Sadhana
//
//  Created by Alexander Koryttsev on 6/2/19.
//  Copyright © 2019 Alexander Koryttsev. All rights reserved.
//

import Foundation
import EasyPeasy

class CSVExporterVC : BaseVC <CSVExporterVM>, UICollectionViewDelegate, UICollectionViewDataSource  {

    let cancelButton = UIButton()
    let container = UIView()
    let doneButton = UIButton()
    let flowLayout : UICollectionViewFlowLayout
    let monthesView : UICollectionView
    let titleLabel = UILabel()
    let transitionController = DimTransitionController()

    override init(_ viewModel: VM) {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: (ScreenWidth - 16.0) / 3.0, height: 40)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        monthesView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init(viewModel)
        modalPresentationStyle = .custom
        transitioningDelegate = transitionController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }

    func setUpViews() {
        view.backgroundColor = .clear
        container.cornerRadius = 16
        container.backgroundColor = .white

        cancelButton.backgroundColor = .white
        cancelButton.cornerRadius = 16
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.setTitleColor(.sdTangerine, for: .normal)
        cancelButton.addTarget(viewModel, action: #selector(CSVExporterVM.close), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.easy.layout( Left(8), Bottom(8), Right(8), Height(57) )

        view.addSubview(container)
        container.easy.layout(Left(8), Right(8), Bottom(8).to(cancelButton))

        doneButton.setTitle("done".localized, for: .normal)
        doneButton.setTitleColor(.sdTangerine, for: .normal)
        doneButton.setTitleColor(.sdSilver, for: .disabled)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        doneButton.addTarget(viewModel, action: #selector(CSVExporterVM.done), for: .touchUpInside)
        container.addSubview(doneButton)
        doneButton.easy.layout( Left(), Bottom(), Right(), Height(57) )

        let separator = UIView()
        separator.backgroundColor = .sdSeparatorGreyColor
        container.addSubview(separator)
        separator.easy.layout(Left(), Bottom().to(doneButton), Right(), Height(0.5))

        container.addSubview(monthesView)
        monthesView.easy.layout(Left(), Bottom().to(separator), Right(), Height(4.0 * flowLayout.itemSize.height))
        configureMonthesView()

        let separator2 = UIView()
        separator2.backgroundColor = .sdSeparatorGreyColor
        container.addSubview(separator2)
        separator2.easy.layout(Left(), Bottom().to(monthesView), Right(), Height(0.5))

        titleLabel.text = "settings.export_csv_exporter_title".localized
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .sdSteel

        container.addSubview(titleLabel)
        titleLabel.easy.layout(Top(16), Left(16), Bottom(16).to(separator2), Right(16))
    }

    func configureMonthesView() {
        monthesView.delegate = self
        monthesView.dataSource = self
        monthesView.register(MonthCell.self, forCellWithReuseIdentifier: "Cell")
        monthesView.isScrollEnabled = false
        monthesView.backgroundColor = .white
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.monthes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MonthCell
        let currentMonth = month(at: indexPath.row)
        cell.titleLabel.text = currentMonth.date.monthShort
        updateSelection(for: cell, with:currentMonth)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentMonth = month(at: indexPath.row)
        viewModel.select(month: currentMonth)
        updateSelection(for: collectionView.cellForItem(at: indexPath) as! MonthCell, with: currentMonth)
        doneButton.isEnabled = viewModel.selectedMothes.count > 0
    }

    func month(at index:Int) -> LocalDate {
        return viewModel.monthes[viewModel.monthes.count - index - 1]
    }

    func updateSelection(for cell: MonthCell, at indexPath: IndexPath) {
        updateSelection(for: cell, with: month(at: indexPath.row))
    }

    func updateSelection(for cell: MonthCell, with month: LocalDate) {
        let isSelected = viewModel.selectedMothes.contains(month)
        let isCurrent = LocalDate().month == month.month

        if isCurrent {
            cell.titleLabel.textColor = isSelected ? .white : .sdTangerine
            cell.titleLabel.font = .systemFont(ofSize: 16, weight:isSelected ? .medium : .regular )
            cell.contentView.backgroundColor = isSelected ? .sdTangerine : .white
        }
        else {
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = .systemFont(ofSize: 16, weight: isSelected ? .regular : .ultraLight)
            cell.contentView.backgroundColor = isSelected ? .sdPaleGrey : .white
        }
    }

    class MonthCell : UICollectionViewCell {
        let titleLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setUpSubviews()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setUpSubviews() {
            contentView.backgroundColor = .white
            contentView.addSubview(titleLabel)
            titleLabel.easy.layout(Edges())
            titleLabel.layer.borderColor = UIColor.sdSeparatorGreyColor.cgColor
            titleLabel.layer.borderWidth = 0.5
            titleLabel.textAlignment = .center
        }
    }
}
