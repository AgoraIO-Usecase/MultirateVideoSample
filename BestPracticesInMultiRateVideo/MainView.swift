//
//  MainView2.swift
//  Demo
//
//  Created by ZYP on 2024/2/6.
//

import UIKit

protocol MainView2Delegate: NSObjectProtocol {
    func mainViewDidTapAction(index: Int)
}

class MainView: UIView {
    private let videoSizelabel = UILabel()
    private let videoView1 = VideoView()
    private let videoView2 = VideoView()
    private let videoView3 = VideoView()
    /// 切换视频分辨率
    private let switchBtn1 = UIButton()
    private let switchBtn2 = UIButton()
    private let switchBtn3 = UIButton()
    weak var delegate: MainView2Delegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCurrentVideoViewDisplay(tag: Int) {
        let videoViews = [videoView1, videoView2, videoView3]
        
        let remoteViews = videoViews.filter { $0.tag != tag }
        remoteViews.forEach { $0.isHidden = true }
        if let currentRemoteView = videoViews.first(where: { $0.tag == tag }) {
            bringSubviewToFront(currentRemoteView)
            currentRemoteView.isHidden = false
        }
    }
    
    func getCurrentVideoView(tag: Int) -> UIView {
        let currentRemoteView = subviews.first(where: { $0.tag == tag })! as! VideoView
        return currentRemoteView.renderView
    }
    
    private func setupUI() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.width
        videoView1.frame = CGRect(x: 0, y: 0, width: width, height: height )
        videoView2.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videoView3.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videoView1.isHidden = true
        videoView2.isHidden = true
        videoView3.isHidden = true
        addSubview(videoView1)
        addSubview(videoView2)
        addSubview(videoView3)
        
        /// 布局 switchBtn
        switchBtn1.setTitle("切到原始", for: .normal)
        switchBtn1.setTitleColor(.white, for: .normal)
        switchBtn1.backgroundColor = .blue
        switchBtn1.showsTouchWhenHighlighted = true
        
        switchBtn2.setTitle("切到720", for: .normal)
        switchBtn2.setTitleColor(.white, for: .normal)
        switchBtn2.backgroundColor = .blue
        switchBtn2.showsTouchWhenHighlighted = true
        
        switchBtn3.setTitle("切到480", for: .normal)
        switchBtn3.setTitleColor(.white, for: .normal)
        switchBtn3.backgroundColor = .blue
        switchBtn3.showsTouchWhenHighlighted = true
        
        let gap: CGFloat = 10
        switchBtn1.frame = CGRect(x: 0, y: height + 10, width: 100, height: 50)
        switchBtn2.frame = CGRect(x: 0, y: height + 10 + 50 + gap, width: 100, height: 50)
        switchBtn3.frame = CGRect(x: 0, y: height + 10 + 2 * (50 + gap), width: 100, height: 50)
        addSubview(switchBtn1)
        addSubview(switchBtn2)
        addSubview(switchBtn3)
        
        
        videoSizelabel.textColor = .blue
        addSubview(videoSizelabel)
        videoSizelabel.frame = CGRect(x: 110, y: height + 10 + 50 + gap, width: UIScreen.main.bounds.size.width - 110, height: 45)
    }
    
    private func commonInit() {
        videoView1.setTagForDisplay(tag: 1)
        videoView2.setTagForDisplay(tag: 2)
        videoView3.setTagForDisplay(tag: 3)
        
        switchBtn1.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
        switchBtn2.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
        switchBtn3.addTarget(self, action: #selector(buttonTap(_:)), for: .touchUpInside)
    }
    
    @objc func buttonTap(_ sender: UIButton) {
        if sender == switchBtn1 {
            delegate?.mainViewDidTapAction(index: 0)
        } else if sender == switchBtn2 {
            delegate?.mainViewDidTapAction(index: 1)
        } else if sender == switchBtn3 {
            delegate?.mainViewDidTapAction(index: 2)
        }
    }
    
    func setVideoSizelabel(text: String) {
        videoSizelabel.text = text
    }
}

/// video view
class VideoView: UIView {
    let renderView = UIView()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(renderView)
        addSubview(nameLabel)
        
        renderView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        renderView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        renderView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        renderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        renderView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: renderView.bottomAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTagForDisplay(tag: Int) {
        self.tag = tag
        if tag == 1 {
            nameLabel.text = "原始"
        }
        else if tag == 2 {
            nameLabel.text = "720"
        }
        else if tag == 3 {
            nameLabel.text = "480"
        }
        
        nameLabel.textColor = .red
    }
}
