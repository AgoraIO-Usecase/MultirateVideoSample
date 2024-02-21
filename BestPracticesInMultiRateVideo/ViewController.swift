//
//  ViewController2.swift
//  Demo
//
//  Created by ZYP on 2024/2/5.
//

import UIKit
import AgoraRtcKit
class ViewController: UIViewController {
    fileprivate let mainView = MainView(frame: .zero)
    private var agoraKit: AgoraRtcEngineKit!
    /// 所有channel 信息
    fileprivate var channelInfos = [ChannelInfo]()
    
    /// 上一个channel 信息
    fileprivate var lastChannelInfo: ChannelInfo?
    /// 当前channel 信息
    fileprivate var currentChannelInfo: ChannelInfo!
    
    /// 标识当前用哪一个connection
    fileprivate var currentUsingConnection1 = false
    
    /// 两个eventHandler 交替使用，用于接收rtc sdk 回调事件
    fileprivate let eventHandler1 = EngineHandler()
    fileprivate let eventHandler2 = EngineHandler()
    
    /// 两个connection 交替使用
    fileprivate var connection1: AgoraRtcConnection?
    fileprivate var connection2: AgoraRtcConnection?
    /// 标识当前是否在切换频道
    fileprivate var isChanging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        commonInit()
        initEngine()
    }
    
    private func setupUI() {
        mainView.frame = .init(origin: .init(x: 0, y: 200), size: view.bounds.size)
        mainView.delegate = self
        view.addSubview(mainView)
    }
    
    private func commonInit() {
        eventHandler1.delegate = self
        eventHandler1.tag = "1"
        eventHandler2.delegate = self
        eventHandler2.tag = "2"
        channelInfos = [ChannelInfo(channenName: "test", uid: 1, videoViewTag: 1),
                        ChannelInfo(channenName: "test_720P_web", uid: 1, videoViewTag: 2),
                        ChannelInfo(channenName: "test_480P_web", uid: 1, videoViewTag: 3)]
    }
    
    private func initEngine() {
        let config = AgoraRtcEngineConfig()
        config.appId = Config.rtcAppId
        config.audioScenario = .default
        config.channelProfile = .liveBroadcasting
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: nil)
    }
    
    private func switchChannel(channelInfo: ChannelInfo) {
        if currentChannelInfo != nil, channelInfo.channenName == currentChannelInfo.channenName {
            showAlertVC(title: "tip", message: "已经在\(channelInfo.channenName)频道中")
            return
        }
        
        if isChanging {
            showAlertVC(title: "tip", message: "请等待切换完成再操作")
            return
        }
        
        isChanging = true
        
        print("=== switchChannel from \(currentChannelInfo?.channenName ?? "no") to \(channelInfo.channenName)")
        
        lastChannelInfo = currentChannelInfo
        currentChannelInfo = channelInfo
        
        currentUsingConnection1 = !currentUsingConnection1
        print("=== switchChannel currentUsingConnection1 \(currentUsingConnection1)")
        
        let connection = AgoraRtcConnection()
        connection.channelId = currentChannelInfo.channenName
        connection.localUid = currentChannelInfo.uid
        eventHandler1.enableEvent = currentUsingConnection1
        eventHandler2.enableEvent = !currentUsingConnection1
        let handler = currentUsingConnection1 ? eventHandler1 : eventHandler2
        
        if currentUsingConnection1 {
            connection1 = connection
        }
        else {
            connection2 = connection
        }
        joinChannel(connection: connection, handler: handler)
    }
    
    private func joinChannel(connection: AgoraRtcConnection, handler: EngineHandler) {
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.audience)
        agoraKit.enableVideo()
        agoraKit.enableLocalVideo(true)
        agoraKit.enableLocalAudio(false)
        let mediaOptions = AgoraRtcChannelMediaOptions()
        mediaOptions.publishMicrophoneTrack = false
        mediaOptions.publishCameraTrack = true
        mediaOptions.autoSubscribeVideo = true
        mediaOptions.autoSubscribeAudio = false
        mediaOptions.clientRoleType = .audience
        
        let result = agoraKit.joinChannelEx(byToken: nil,
                                            connection: connection,
                                            delegate: handler,
                                            mediaOptions: mediaOptions,
                                            joinSuccess: nil)
        if result != 0 {
            print("=== joinChannelEx call failed: \(result), please check your params")
            showAlertVC(title: "Error", message: "joinChannelEx fail \(result)")
            isChanging = false
        }
        else {
            print("=== joinChannel success \(currentChannelInfo.channenName) ")
        }
    }
    
    private func setupRemoteVideo(uid: UInt) {
        let remoteView = mainView.getCurrentVideoView(tag: currentChannelInfo.videoViewTag)
        print("=== setupRemoteVideo uid \(uid) tag:\(currentChannelInfo.videoViewTag) view:\(remoteView)")
        let connection = currentUsingConnection1 ? connection1 : connection2
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .fit
        videoCanvas.view = remoteView
        let ret = agoraKit.setupRemoteVideoEx(videoCanvas, connection: connection!)
        if ret != 0 {
            print("=== setupRemoteVideo call failed: \(ret), please check your params")
            showAlertVC(title: "Error", message: "setupRemoteVideoEx fail \(ret)")
        }
        else {
            print("=== setupRemoteVideo success \(uid)")
        }
    }
    
    fileprivate func leaveChannelIfNeeded() {
        print("=== leaveChannelIfNeeded")
        
        let lastUsingConnection1 = !currentUsingConnection1
        guard let connection = lastUsingConnection1 ? connection1 : connection2 else {
            print("=== leaveChannelIfNeeded no connection can leave")
            return
        }
        
        if lastUsingConnection1 {
            connection1 = nil
        }
        else {
            connection2 = nil
        }
        
        let result = agoraKit.leaveChannelEx(connection)
        if result != 0 {
            print("=== leaveChannelEx call failed: \(result), please check your params")
            showAlertVC(title: "Error", message: "leaveChannelEx fail \(result)")
        }
        else {
            print("=== leaveChannelEx success \(connection.channelId)")
        }
    }
    
    func showAlertVC(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension ViewController: MainView2Delegate {
    func mainViewDidTapAction(index: Int) {
        let channelInfo = channelInfos[index]
        switchChannel(channelInfo: channelInfo)
    }
}

extension ViewController: EventDelegate {
    func didJoinedOfUid(handler: EngineHandler, uid: UInt, elapsed: Int) {
        setupRemoteVideo(uid: uid)
    }
    
    func firstRemoteVideoFrameOfUid(uid: UInt, size: CGSize, elapsed: Int) {
        print("=== setCurrentVideoViewDisplay tag:\(currentChannelInfo.videoViewTag)")
        
        /// 17ms 后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.017) { [weak self] in
            guard let self = self else { return }
            mainView.setCurrentVideoViewDisplay(tag: currentChannelInfo.videoViewTag)
            leaveChannelIfNeeded()
            isChanging = false
        }
    }
    
    func remoteVideoStats(stats: AgoraRtcRemoteVideoStats) {
        mainView.setVideoSizelabel(text: "current videoStats w:\(stats.width) h:\(stats.height)")
    }
}
