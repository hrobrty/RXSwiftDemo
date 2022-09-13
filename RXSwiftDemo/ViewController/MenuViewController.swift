//
//  MenuViewController.swift
//  RXSwiftDemo
//
//  Created by yi he on 2022/9/13.
//

import UIKit

class MenuViewController: UIViewController {

    let disposeBag = DisposeBag()
    let menuViewModel = MenuViewModel()
    
    let identifier = String(describing: UITableViewCell.self)
    
    lazy var tableView = UITableView().then {
        $0.frame = self.view.bounds
       // $0.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindToModel()
        reloadData()
    }
 
    func setupUI() {
        self.view.addSubview(self.tableView)
    }
    
    func reloadData() {
        menuViewModel.parseJsonStr()
    }
    
    func bindToModel() {
        menuViewModel.menuSubject
            .bind(to: tableView.rx.items) { [weak self] (tableView, row, model) in
                guard let `self` = self else { return UITableViewCell() }
                /// 怎么设置子标题（不需要注册） https://blog.csdn.net/weixin_42349140/article/details/80947266
                let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: self.identifier)
                cell.textLabel?.text = "\(row)：\(model?.title ?? "")"
                cell.detailTextLabel?.text = model?.body ?? ""
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
