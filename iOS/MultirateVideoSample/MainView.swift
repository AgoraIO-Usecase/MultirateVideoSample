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
    let videoView = VideoView()
    
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
    
    private func setupUI() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.width
        videoView.frame = CGRect(x: 0, y: 0, width: width, height: height )
        videoView.frame = CGRect(x: 0, y: 0, width: width, height: height )
        addSubview(videoView)
        addSubview(videoView)

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
    let renderView1 = UIView()
    let renderView2 = UIView()
    private let nameLabel = UILabel()
    /// indicate which video view is using
    var currentUsingVideoView1 = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(renderView1)
        addSubview(renderView2)
        addSubview(nameLabel)
        
        renderView1.translatesAutoresizingMaskIntoConstraints = false
        renderView2.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        renderView1.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        renderView1.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        renderView1.topAnchor.constraint(equalTo: topAnchor).isActive = true
        renderView1.bottomAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        
        renderView2.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        renderView2.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        renderView2.topAnchor.constraint(equalTo: topAnchor).isActive = true
        renderView2.bottomAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: renderView2.bottomAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        renderView1.tag = 1
        renderView2.tag = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// dispaly video view
    func setCurrentVideoViewNeedToDisplay(text: String) {
        if currentUsingVideoView1 {
            nameLabel.text = text + "      [viewTag:\(renderView1.tag)]"
            renderView1.isHidden = false
            renderView2.isHidden = true
        } else {
            nameLabel.text = text + "      [viewTag:\(renderView2.tag)]"
            renderView2.isHidden = false
            renderView1.isHidden = true
        }
        nameLabel.textColor = .red
    }
    
    /// get a render view to display video
    func getAvaiableRenderView() -> UIView {
        currentUsingVideoView1 = !currentUsingVideoView1
        let renderView = currentUsingVideoView1 ? renderView1 : renderView2
        return renderView
    }
}
