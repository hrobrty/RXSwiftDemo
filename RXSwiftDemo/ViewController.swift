//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by yi he on 2022/9/9.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate lazy var sequence = Observable<Void>.empty()
    lazy var publishSubject = PublishSubject<String>()
    lazy var behaviorSubject = BehaviorSubject<PublishSubject>(value: publishSubject)
    lazy var behaviorRelay = BehaviorRelay(value: publishSubject)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
        //页面显示状态完毕
        self.rx.isVisible
            .subscribe(onNext: { visible in
                print("当前页面显示状态：\(visible)")
            }).disposed(by: disposeBag)
        
        //页面加载完毕
        self.rx.viewDidLoad
            .subscribe(onNext: {
                print("viewDidLoad")
            }).disposed(by: disposeBag)
        
        //页面将要显示
        self.rx.viewWillAppear
            .subscribe(onNext: { animated in
                print("viewWillAppear")
            }).disposed(by: disposeBag)
        
        //页面显示完毕
        self.rx.viewDidAppear
            .subscribe(onNext: { animated in
                print("viewDidAppear")
            }).disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        behaviorRelay.accept(publishSubject)
    }


    
}

