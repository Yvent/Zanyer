//
//  Zanyer.swift
//  Zany-Pro
//
//  Created by 周逸文 on 2018/3/21.
//  Copyright © 2018年 YV. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


/// The basic model that the player needs.
///
/// 播放器需要的基本数据模型
public struct ZanyerModel {
    
    /// - songName: The song name
    /// - 歌曲名
    ///
    /// - singer: The singer's name
    /// - 歌手名
    ///
    /// - songURL: The song url
    /// - 歌曲地址
    ///
    /// - songImageURL: Cover the url
    /// - 封面地址
    ///
    /// - interval: The song time
    /// - 歌曲时长
    
    let songName: String
    let singer: String
    let songURL: String
    let songImageURL: String
    let interval: Int
    
}

/// The progress of the closure
///
/// 进度闭包
public typealias ZanyerProgressBlock = (_ progress: Float)-> Void
/// Remote control center closure.
///
/// 远程控制中心闭包
public typealias ZanyerCommandCenterBlock = ()-> Void

// MARK: - This is a singleton.(单例)

/// Responsible for player function processing, state callback and some reusable code implementation.
///
/// 负责播放器功能处理，状态回调和一些可复用代码的实现
public class Zanyer: NSObject {
    
    public var commandCenterPlayBlock: ZanyerCommandCenterBlock?
    public var commandCenterNextBlock: ZanyerCommandCenterBlock?
    public var commandCenterPrveBlock: ZanyerCommandCenterBlock?
    
    let ZanyNotiCenter = NotificationCenter.default
    
    /// the zany
    ///
    ///  Zany实例
    private var zany: Zany?
    
    ///  the zanyModel
    ///
    ///  封装的常用数据模型
    private var zanyModel: ZanyerModel?
    
    ///  the zanyItem
    ///
    ///  player item
    private var zanyItem: AVPlayerItem?
    
    /// play progress block
    ///
    /// 播放进度
    public var playProgressBlock: ZanyerProgressBlock?
    
    /// loaded progress block
    ///
    /// 加载进度
    public var loadedProgressBlock: ZanyerProgressBlock?
    
    ///  totaltime
    ///
    ///  currentItem 总时间
    private var totalTmie: Float64?
    ///  the play progress
    ///
    ///  播放进度
    private var progress: Float? {
        willSet{
            if let progressBlock = self.playProgressBlock,let newProgress = newValue {
                progressBlock(newProgress)
            }
        }
        didSet{}
    }
    
    ///  the loadedProgress
    ///
    ///  加载进度
    private var loadedProgress: Float? {
        willSet{
            if let progressBlock = self.loadedProgressBlock,let newProgress = newValue {
                progressBlock(newProgress)
            }
        }
        didSet{}
    }
    /// callback called of state's change
    ///
    ///  播放状态改变时的回调
    public var onStateChanged: (( _ state: State) -> (Void))? = nil
    
    /// current state
    ///
    /// 当前播放状态
    public private(set) var state: State = .paused {
        didSet {
            self.onStateChanged?(state)
        }
    }
    ///  Remote control center - Lock screen
    ///
    ///  远程控制中心 - 锁屏状态下
    private var remoteCommandCenter: MPRemoteCommandCenter?
    
    static let shared = Zanyer()
    
    fileprivate override init() {
        super.init()
        
        ///Initialize the remote control center.
        ///初始化就设置远程控制中心
        self.setupRemoteCommand()
        
    }
    
    ///  Start playing
    ///
    ///  开始播放
    @discardableResult
    public func playMusic(model: ZanyerModel) -> Zanyer {
        self.zanyModel = model
        self.configZany(model: model)
        return self
    }
    
    ///  continue play
    ///
    ///  继续播放
    public func continueMusic() {
        self.zany?.play()
    }
    
    ///  pause play
    ///
    ///  暂停播放
    public func pauseMusic() {
        self.zany?.pause()
    }
    
    /// Create a Zany instance through ZanyerModel.
    ///
    /// 通过ZanyerModel创建一个Zany实例
    private func configZany(model: ZanyerModel) {
        // Audio interruption
        // 音频中断
        ZanyNotiCenter.addObserver(self, selector: #selector(audioInterruptted(_:)), name: NSNotification.Name.AVAudioSessionInterruption, object: nil)
        // Audio route change
        // 音频改变线路（耳机插拔）
        ZanyNotiCenter.addObserver(self, selector: #selector(audioRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        guard let url = URL(string: model.songURL) else {return}
        let zany = Zany(url: url, observer: { [weak self] (_, progress) -> (Void) in
            
            guard let unwrapped = self  else{ return }
            unwrapped.progress = progress
            
            }, ItemAddObserver: { [weak self](_, item) -> (Void) in
                
                guard let unwrapped = self  else{ return }
                unwrapped.zanyItem = item
                item.addObserver(unwrapped, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                item.addObserver(unwrapped, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
                // 缓冲区空了，需要等待数据
                item.addObserver(unwrapped, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
                // 缓冲区有足够数据可以播放了
                item.addObserver(unwrapped, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
        }) {  [weak self] (_, item) -> (Void) in
            
            guard let unwrapped = self  else{ return }
            item.removeObserver(unwrapped, forKeyPath: "status")
            item.removeObserver(unwrapped, forKeyPath: "loadedTimeRanges")
            item.removeObserver(unwrapped, forKeyPath: "playbackBufferEmpty")
            item.removeObserver(unwrapped, forKeyPath: "playbackLikelyToKeepUp")
            
        }
        
        zany.onStateChanged = {[weak self] (_, state) in
            guard let unwrapped = self  else{ return }
            unwrapped.state = state
            
        }
        
        zany.play()
        self.zany = zany
        
        updateLockScreen(model)
        
    }
    
    
    /// KVO
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let item = object as? AVPlayerItem else {return}
        
        if item == self.zanyItem  {
            
            if keyPath == "status"{
                switch item.status {
                case .readyToPlay: // readyToPlay
                    totalTmie = CMTimeGetSeconds(item.duration)
                case .failed: // failed
                    print("failed")
                case .unknown: // unknown
                    print("unknown")
                }
            }else if keyPath == "loadedTimeRanges" {
                
                let loadedTimeRanges = item.loadedTimeRanges
                if  let timeRange = loadedTimeRanges.first?.timeRangeValue {
                    let startSeconds = CMTimeGetSeconds(timeRange.start)
                    let durationSeconds = CMTimeGetSeconds(timeRange.duration)
                    let result = startSeconds + durationSeconds
                    guard let total = totalTmie else {
                        return
                    }
                    loadedProgress = Float(result/total)
                }
            }else if keyPath == "playbackBufferEmpty" {
                print("playbackBufferEmpty")
            }else if keyPath == "playbackLikelyToKeepUp" {
                print("playbackLikelyToKeepUp")
            }
            
        }
    }
    
    
    /// Audio interruption
    ///
    /// 音频中断
     @objc private func audioInterruptted(_ noti: NSNotification) {
        
        if let InterrupttedDict = noti.userInfo,
            let interruptionTypeRawValue = InterrupttedDict[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: interruptionTypeRawValue) {
            
            switch type {
            case .began:  // 开始中断
                self.pauseMusic()
            case .ended:  // 结束中断
                self.continueMusic()
            }
        }
        
    }
    
    /// Audio route change
    ///
    /// 音频改变线路（耳机插拔）
    @objc private func audioRouteChange(_ noti: NSNotification) {
        
        if let InterrupttedDict = noti.userInfo ,
            let routeChangeReasonRawValue = InterrupttedDict[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let type = AVAudioSessionRouteChangeReason(rawValue: routeChangeReasonRawValue){
            
            switch type {
            case .newDeviceAvailable:  // 耳机插入
                self.continueMusic()
                break
            case .oldDeviceUnavailable:    // 耳机拔掉  拔掉耳机继续播放
                self.pauseMusic()
            default:
                break
            }
        }
        
    }
    
    ///  Lock screen
    ///
    ///  锁屏
    private func setupRemoteCommand() {
        
        let remoteCenter = MPRemoteCommandCenter.shared()
        
        remoteCenter.playCommand.isEnabled = true
        remoteCenter.playCommand.addTarget(self, action: #selector(playOrPauseEvent(_:)))
        
        remoteCenter.pauseCommand.isEnabled = true
        remoteCenter.pauseCommand.addTarget(self, action: #selector(playOrPauseEvent(_:)))
        
        remoteCenter.togglePlayPauseCommand.isEnabled = true
        remoteCenter.togglePlayPauseCommand.addTarget(self, action: #selector(playOrPauseEvent(_:)))
        
        remoteCenter.nextTrackCommand.isEnabled = true
        remoteCenter.nextTrackCommand.addTarget(self, action: #selector(playNextEvent(_:)))
        
        remoteCenter.previousTrackCommand.isEnabled = true
        remoteCenter.previousTrackCommand.addTarget(self, action: #selector(playPreviousEvent(_:)))
        
        self.remoteCommandCenter = remoteCenter
        
    }
    /// remove RemoteCommandCenter
    ///
    /// 移除远程控制中心
    private func removeRemoteCommand() {
        remoteCommandCenter?.togglePlayPauseCommand.isEnabled = false
        remoteCommandCenter?.togglePlayPauseCommand.removeTarget(self)
        remoteCommandCenter?.pauseCommand.removeTarget(self)
        remoteCommandCenter?.playCommand.removeTarget(self)
        remoteCommandCenter?.nextTrackCommand.removeTarget(self)
        remoteCommandCenter?.previousTrackCommand.removeTarget(self)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    @objc private func playOrPauseEvent(_ event: MPRemoteCommandEvent) {
        guard let block = commandCenterPlayBlock  else { return  }
        block()
    }
    @objc private func playNextEvent(_ event: MPRemoteCommandEvent) {
        guard let block = commandCenterNextBlock  else { return  }
        block()
    }
    @objc private func playPreviousEvent(_ event: MPRemoteCommandEvent) {
        guard let block = commandCenterPrveBlock  else { return  }
        block()
    }
    
    ///  update Lock Screen
    ///
    /// 更新锁屏界面显示歌曲信息
    private func updateLockScreen(_ model: ZanyerModel) {
        
        var info = [String : AnyObject]()
        // songName
        info[MPMediaItemPropertyTitle] = model.songName as AnyObject
        // singer
        info[MPMediaItemPropertyArtist] = model.singer as AnyObject
        // interval
        info[MPMediaItemPropertyPlaybackDuration] = model.interval as AnyObject
        //ongImage
        if let imageUrl = URL(string: model.songImageURL) ,
            let imageData = try? Data(contentsOf: imageUrl),
            let newImage = UIImage(data: imageData) {
            
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: newImage)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /// remove all
    public func removeAll()  {
        
        removeRemoteCommand()
        self.commandCenterPlayBlock = nil
        self.commandCenterNextBlock = nil
        self.commandCenterPrveBlock = nil
        self.zany = nil
        self.zanyModel = nil
        self.zanyItem = nil
        self.playProgressBlock = nil
        self.loadedProgressBlock = nil
        self.totalTmie = nil
        self.progress = nil
        self.loadedProgress = nil
        self.onStateChanged = nil
        self.state = .paused
        self.remoteCommandCenter = nil
        
        
    }
    
    /// Settings can be played in the background.
    ///
    /// 设置可以后台播放
    public func setSessionActive() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        } catch {
            print("AVAudioSession init failed")
        }
    }
    

}
