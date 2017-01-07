//
//  ZHPlayerView.swift
//  ZHPlayer
//
//  Created by Hayder on 2017/1/3.
//  Copyright © 2017年 Hayder. All rights reserved.
//  视屏播放的View

import UIKit
import AVFoundation

class ZHPlayerView: UIView {
    
    //视屏的URL
    var urlSrting: String?{
        
        didSet{
            
            guard let urlSrting = urlSrting, let url = URL(string: urlSrting) else {
                
                return
            }
            
            playerItem = AVPlayerItem(url: url)
            
            player.replaceCurrentItem(with: playerItem)
            //设置完playerItem 监听item的 status 和 loadedTimeRanges 属性
            addObserverProperty()
            
            //观察播放进度
            playerTimeObserve = observePlayerTimeWithItem(item: playerItem!)
        }
    }
    
    //1.播放器播放
    func Play(){
        player.play()
    }
    
    //2.播放器暂停
    func Pause(){
        player.pause()
    }
    
    fileprivate lazy var operationview: ZHPlayerOperationView = ZHPlayerOperationView.operationView()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        originalFrame = frame
        
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    
    }
    
    //filePrivate  lazy
    fileprivate var playerItem: AVPlayerItem?
    
    fileprivate lazy var player: AVPlayer = AVPlayer()
    
    lazy var playerLayer: AVPlayerLayer = {
        
        let playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer.videoGravity = AVLayerVideoGravityResize
        return playerLayer
    }()

    //视频总时间
    fileprivate var totalTime: TimeInterval{
        
        guard let totalTime = playerItem?.duration else {
            
            return 0
        }
        
        return CMTimeGetSeconds(totalTime)
    }
    
    //缓冲时间
    fileprivate var loadedTime: TimeInterval{
        
        let loadedTimeRange = playerItem?.loadedTimeRanges
        
        guard let timeRange = loadedTimeRange?.first as? CMTimeRange else {
            
            return 0
        }
        
        let startTime: TimeInterval = CMTimeGetSeconds(timeRange.start)
        let durationTime: TimeInterval = CMTimeGetSeconds(timeRange.duration)
        
        return startTime + durationTime
    }
    
    //播放观察者
    fileprivate var playerTimeObserve: Any?
    
    //记录下初始的frame
    var originalFrame: CGRect = CGRect()
    
    //记录下playerView的父视图
    var originalSuperView: UIView?
    
    
    //销毁时移除
    deinit {
        
        //1.移除kvo观察对象
        player.removeObserver(self, forKeyPath: "status")
        player.removeObserver(self, forKeyPath: "loadedTimeRanges")
        
        //2.观察播放时间观察者移除
        player.removeTimeObserver(playerTimeObserve!)
        playerTimeObserve = nil
        
        //移除屏幕旋转的通知
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        operationview.frame = self.bounds
        playerLayer.frame = self.layer.bounds
    }
}

//MARK:- privateFunc
extension ZHPlayerView{
    
    //初始化UI
    fileprivate func setupUI(){
        
        //0.添加播放器的layer
        self.layer.addSublayer(playerLayer)
        
        //1.添加操作View
        addSubview(operationview)
        
        //滑块拖动时
        operationview.sliderChanged = {[weak self] (value) in
            
            let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(1*UInt64(NSEC_PER_SEC)))
            
            self?.playerItem?.seek(to: time)
        }

    }
    
    //添加监听属性
    fileprivate func addObserverProperty(){
        
        //监听playItem的状态属性
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        //监听缓冲进度的属性
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
    }
    
    //观察播放进度
    fileprivate func observePlayerTimeWithItem(item: AVPlayerItem) -> Any{
        
        //1/30s执行一次 查看播放进度
        let observePlayerTime = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 30), queue: DispatchQueue.main, using: {[weak self] (time) in
            
            let currentTimeSecond = TimeInterval(item.currentTime().value)/TimeInterval(item.currentTime().timescale)
            
            //更新operationview的界面
            self?.operationview.playProgress.value = Float(currentTimeSecond)
            self?.operationview.currentTime.text = String.convertTimeWithSecond(second: currentTimeSecond)
        })
        
        return observePlayerTime
    }
}

//MARK:- 观察者属性
extension ZHPlayerView{
    
    //KVO监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            
            let status = change?[NSKeyValueChangeKey.newKey] as? Int
            /**
             status 3种状态
             
             unknown 0
             readyToPlay 1
             failed  2
             */
            if status == 1 { //准备播放了
                
                //设置视频一些属性
                let time = playerItem?.duration
                
                var second: TimeInterval = 0
                
                if let time = time {
                    
                    second = CMTimeGetSeconds(time)
                }
                
                //0.设置播放进度条的最大值
                operationview.playProgress.maximumValue = Float(second)
                //1.设置播放的最大时间
                operationview.totalTime.text = String.convertTimeWithSecond(second: second)
                //2.设置开始播放
                player.play()
                
                //3.添加定时器
                operationview.addTimer()
            }else
            {
                print("视频播放失败")
            }
        }else if keyPath == "loadedTimeRanges" //缓冲属性
        {
            if operationview.isSlider == false
            {
                let loadedTime = self.loadedTime //缓冲时间
                let totalTime = self.totalTime //总时间
                
                //设置缓冲进度条
                operationview.loadedProgress.setProgress(Float(CGFloat(loadedTime/totalTime)), animated: true)
            }
        }
    }
    
}



