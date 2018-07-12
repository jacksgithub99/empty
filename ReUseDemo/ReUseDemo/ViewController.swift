//
//  ViewController.swift
//  ReUseDemo
//
//  Created by Weshare on 2018/7/11.
//  Copyright © 2018年 Weshare. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var belowView: UIView!
    @IBOutlet weak var aboveView: UIView!
    
    var frameView: UIView!
    
    var index = 0
    
    //MARK: Lifecircle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        initData()
    }
    //    初始化UI
    func setupUI() {
        frameView = UIView(frame: CGRect(x: 150, y: 0, width: 88, height: 99))
        frameView.backgroundColor = UIColor.purple
        view.addSubview(frameView)
        
        let index_red = view.index(ofAccessibilityElement: redView)
        let index_green = view.index(ofAccessibilityElement: greenView)
        let index_inner = view.index(ofAccessibilityElement: innerView)
        let index_frame = view.index(ofAccessibilityElement: frameView)
        let index_label = view.index(ofAccessibilityElement: label)
        
        debugPrint("%zd,%zd,%zd,%zd,%zd",index_red, index_green, index_inner, index_frame, index_label)

    }
    //    初始化数据
    func initData() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - touch event
    
    @IBAction func btnClick(_ sender: UIButton) {
        
        
        if index == 0 {
            JKZoomViewsManager.sharedInstance.belowView = belowView
            JKZoomViewsManager.sharedInstance.show(zoomView: greenView)
        }else if index == 1 {
            JKZoomViewsManager.sharedInstance.belowView = label
            JKZoomViewsManager.sharedInstance.show(zoomView: innerView)
        }else if index == 2 {
            JKZoomViewsManager.sharedInstance.aboveView = aboveView
            JKZoomViewsManager.sharedInstance.show(zoomView: redView)
        }else if index == 3 {
            JKZoomViewsManager.sharedInstance.show(zoomView: frameView)
            index = -1
        }
        index += 1
        
    }
    
    //MARK: task
    
    //MARK: request

}
