//
//  ViewController.swift
//  Zanyer-Demo
//
//  Created by 周逸文 on 2018/3/27.
//  Copyright © 2018年 YV. All rights reserved.
//

import UIKit
import Zanyer
import SnapKit

///Capabilites -> Background Modes -> selected the first

/*
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 </dict>
 
 add to info.plist
 */
///   Zanyer.shared.setSessionActive() add to appdelegate
///

//MARK: UI
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let widthProportion: CGFloat = 0.85

class ViewController: UIViewController {
    
    
    var currentIndex: Int = 0
    
    var isStopAnimation: Bool = false
    
    let models = [ ZanyerModel(songName: "Somebody That I Used to Know",
                               singer: "Gotye",
                               songURL: "http://ws.stream.qqmusic.qq.com/C100001JITda3sTVCc.m4a?fromtag=38",
                               songImageURL:"https://y.gtimg.cn/music/photo_new/T002R300x300M000000Zn8Hd2djP4Q.jpg?max_age=2592000",
                               interval: 245),
                   ZanyerModel(songName: "我的滑板鞋",
                               singer: "张川",
                               songURL: "http://ws.stream.qqmusic.qq.com/C100000UXxU64SkE0b.m4a?fromtag=38",
                               songImageURL:"https://y.gtimg.cn/music/photo_new/T002R300x300M000001rJsvW1tX9ox.jpg?max_age=2592000",
                               interval: 191)
    ]
    
    
    lazy var backimageV: UIImageView = {
        let make = UIImageView()
        let blurEffectView = UIVisualEffectView()
        blurEffectView.frame = make.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.effect = UIBlurEffect(style: .dark)
        make.addSubview(blurEffectView)
        return make
    }()
    
    lazy var songNameLab: UILabel = {
        let make = UILabel()
        make.textColor = UIColor.white
        make.textAlignment = .center
        make.font = UIFont.systemFont(ofSize: 20)
        return make
    }()
    
    lazy var singerLab: UILabel = {
        let make = UILabel()
        make.textColor = UIColor.white
        make.textAlignment = .center
        make.font = UIFont.systemFont(ofSize: 10)
        return make
    }()
    
    lazy var songImageV: UIImageView = {
        let make = UIImageView()
        make.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        make.layer.borderWidth = 5
        make.layer.cornerRadius = ScreenWidth*widthProportion/2
        make.layer.masksToBounds = true
        return make
    }()
    

    lazy var playerSlidder: UISlider = {
        let make = UISlider()
        make.setThumbImage(UIImage(named: "ic_seek_bar_progress_btn"), for: .normal)
        make.setThumbImage(UIImage(named: "ic_seek_bar_progress_btn"), for: .highlighted)
        make.thumbTintColor = UIColor(red: 51/255, green: 190/255, blue: 122/255, alpha: 1)
        make.tintColor = UIColor(red: 51/255, green: 190/255, blue: 122/255, alpha: 1)
       make.isUserInteractionEnabled = false
        return make
    }()
    
    lazy var playBtn: UIButton = {
        let make = UIButton()
        make.setImage(UIImage(named: "ic_play_btn_play"), for: .normal)
        make.setImage(UIImage(named: "ic_play_btn_pause"), for: .selected)
        make.addTarget(self, action: #selector(didplayBtn), for: .touchUpInside)
        return make
    }()
    
    lazy var prevBtn: UIButton = {
        let make = UIButton()
        make.setImage(UIImage(named: "ic_play_btn_prev"), for: .normal)
        make.setImage(UIImage(named: "ic_play_btn_prev_pressed"), for: .selected)
        make.addTarget(self, action: #selector(didprevBtn), for: .touchUpInside)
        return make
    }()
    
    lazy var nextBtn: UIButton = {
        let make = UIButton()
        make.setImage(UIImage(named: "ic_play_btn_next"), for: .normal)
        make.setImage(UIImage(named: "ic_play_btn_next_pressed"), for: .selected)
        make.addTarget(self, action: #selector(didnextBtn), for: .touchUpInside)
        return make
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        initZanyer()
        
        
    }
    func initZanyer() {
        
    
        Zanyer.shared.playProgressBlock = {[weak self] (progress) in
              guard let unwrapped = self  else{ return }
            unwrapped.playerSlidder.setValue(progress, animated: true)
        }
        
        
        Zanyer.shared.commandCenterPlayBlock = { [weak self] in
            guard let unwrapped = self  else{ return }
            /// play or pause
            unwrapped.didplayBtn()
        }
        
        Zanyer.shared.commandCenterNextBlock = { [weak self] in
            guard let unwrapped = self  else{ return }
            /// next
            unwrapped.nextmusic()
            
        }
        
        Zanyer.shared.commandCenterPrveBlock = { [weak self] in
            guard let unwrapped = self  else{ return }
            /// prve
            unwrapped.prvemusic()
        }
        
        Zanyer.shared.onStateChanged = {[weak self] (newState) in
            
            guard let unwrapped = self  else{ return }
            switch newState {
            case .running:
                unwrapped.playBtn.isSelected = true
                unwrapped.startRotating()
            case .paused:
                unwrapped.playBtn.isSelected = false
                unwrapped.stopRotating()
            case .finished:
                print("finished")
                unwrapped.nextmusic()
            }
        }
        
        playmusic()
    }
    
    
    func initUI() {
        self.view.addSubview(backimageV)
        self.view.addSubview(songNameLab)
        self.view.addSubview(singerLab)
        self.view.addSubview(songImageV)
        
        self.view.addSubview(playerSlidder)
        self.view.addSubview(playBtn)
        self.view.addSubview(prevBtn)
        self.view.addSubview(nextBtn)
        
        
        backimageV.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        songNameLab.snp.makeConstraints { (make) in
            make.width.equalTo(ScreenWidth-100)
            make.top.equalTo(30)
            make.centerX.equalTo(self.view)
        }
        singerLab.snp.makeConstraints { (make) in
            make.width.equalTo(ScreenWidth-100)
            make.top.equalTo(songNameLab.snp.bottom).offset(10)
            make.centerX.equalTo(songNameLab)
        }
        songImageV.snp.makeConstraints { (make) in
            make.width.height.equalTo(ScreenWidth*widthProportion)
            make.centerX.equalTo(self.view)
            make.top.equalTo(singerLab.snp.bottom).offset(50)
        }
        
        playerSlidder.snp.makeConstraints { (make) in
            make.centerY.equalTo(backimageV.snp.bottom).offset(-141)
            make.left.equalTo(backimageV).offset(50)
            make.right.equalTo(backimageV).offset(-50)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(70)
            make.centerX.equalTo(backimageV)
            make.top.equalTo(playerSlidder.snp.bottom).offset(20)
        }
        
        prevBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(60)
            make.left.equalTo(backimageV).offset(50)
            make.centerY.equalTo(playBtn)
        }
        nextBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(60)
            make.right.equalTo(backimageV).offset(-50)
            make.centerY.equalTo(playBtn)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateUI(model: ZanyerModel) {
        
        if let imageUrl = URL(string: model.songImageURL) ,
            let imageData = try? Data(contentsOf: imageUrl),
            let newImage = UIImage(data: imageData) {
            self.backimageV.image = newImage
            self.songImageV.image = newImage
        }
        
        self.songNameLab.text = model.songName
        self.singerLab.text = model.singer
        
    }
    
    func startRotating() {
        
        isStopAnimation = false
        UIView.animate(withDuration: 5, delay: 0, options: .curveLinear, animations: {
            self.songImageV.transform =  self.songImageV.transform.rotated(by: CGFloat(Double.pi))
        }) { (finished) in
            
            if self.isStopAnimation == false {
                self.startRotating()
            }
        }
        
    }
    
    func stopRotating() {
        isStopAnimation = true
        self.songImageV.layer.removeAllAnimations()
    }
    @objc func didplayBtn() {
        
        if Zanyer.shared.state.isPaused == true{
            self.continuemusic()
        }else if Zanyer.shared.state.isRunning == true{
            self.pausedmusic()
        }
        
    }
    @objc func didprevBtn() {
        prvemusic()
    }
    @objc func didnextBtn() {
        nextmusic()
    }
    func playmusic() {
        
        Zanyer.shared.playMusic(model: models[currentIndex])
        updateUI(model:  models[currentIndex])
        
    }
    
    func pausedmusic()  {
        Zanyer.shared.pauseMusic()
    }
    
    func continuemusic() {
        Zanyer.shared.continueMusic()
    }
    func prvemusic() {
        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = models.count-1
        }
        playmusic()
    }
    
    func nextmusic()  {
        currentIndex += 1
        if currentIndex > models.count-1 {
            currentIndex = 0
        }
        playmusic()
    }
    

    
}
