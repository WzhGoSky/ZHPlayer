//
//  ViewController.swift
//  ZHPlayer
//
//  Created by Hayder on 2017/1/3.
//  Copyright © 2017年 Hayder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.创建播放视图
        let playView = ZHPlayerView(frame:  CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width*0.6))
        playView.urlSrting = "http://mov.bn.netease.com/open-movie/nos/mp4/2015/12/29/SBB3FG5M0_sd.mp4"
        view.addSubview(playView)
        
    }
}

