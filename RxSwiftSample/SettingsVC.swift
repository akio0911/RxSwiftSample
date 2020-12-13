//
//  SettingsVC.swift
//  RxSwiftSample
//
//  Created by Nekokichi on 2020/12/12.
//　ライフサイクルメソッドを用いてViewを描画、
/*
 RxDataSourcesを使って変わること
 ・delegateメソッドの大半が不要
 ・セクションとセルの値や設定を別ファイルで整理できた
 ・rx.itemDelete, rx.itemSelected、のように、rx.状態/プロパティ、で変更を検知し、次に実行する処理をかける
 */

import UIKit
import RxSwift
import RxDataSources

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var disposeBag = DisposeBag()

    // numberOfSections,tableReloadの役割
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SettingsSectionModel>(configureCell: configureCell)

    // cellForRowAtの役割ーセルを返す
    private lazy var configureCell: RxTableViewSectionedReloadDataSource<SettingsSectionModel>.ConfigureCell =
        { [weak self]  (dataSource, tableView, indexPath, _) in
            let item = dataSource[indexPath]
            switch item {
            case .account, .security, .notification, .contents, .sounds, .dataUsing, .accessibility, .one, .two:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = item.title
                return cell
            case .description(let text):
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel?.text = text
                cell.isUserInteractionEnabled = false
                return cell
            }
        }

    private var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        setupTableView()
        setupViewModel()
    }

    // 起動時の設定
    private func setupViewController() {
        navigationItem.title = "設定"
    }

    // TableViewの設定
    private func setupTableView() {
        // delegateやセルの登録
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset.bottom = 12.0
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        // didTapSelectRowAt-セルをタップ時の処理
        // itemSelected時にsubscribe(タップされたら購読)
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let item_ = self?.dataSource[indexPath] else {return}
                self?.tableView.deselectRow(at: indexPath, animated: true)
                // タップ後の処理などを記述
            })
            .disposed(by: disposeBag)
    }


    private func setupViewModel() {
        viewModel = SettingsViewModel()
        // ViewModelとdataSourceを紐付け？
        viewModel.items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.updateItem()
    }

}

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = dataSource[indexPath]
        return item.rowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = dataSource[section]
        return section.model.headerHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let section = dataSource[section]
        return section.model.footerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        return headerView
    }
}
