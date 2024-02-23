//
//  ViewController2+Info.swift
//  Demo
//
//  Created by ZYP on 2024/2/6.
//

import Foundation
import AgoraRtcKit

extension ViewController {
    struct ChannelInfo {
        let channenName: String
        let uid: UInt
        let videoViewTag: Int
        var tagName: String {
            if channenName == "test" {
                return "原始"
            } else if channenName == "test_720P_web" {
                return "720P"
            } else {
                return "480P"
            }
        }
    }
}

protocol EventDelegate: NSObjectProtocol {
    func didJoinedOfUid(handler: EngineHandler, uid: UInt, elapsed: Int)
    func firstRemoteVideoFrameOfUid(uid: UInt, size: CGSize, elapsed: Int)
    func remoteVideoStats(stats: AgoraRtcRemoteVideoStats)
}

class EngineHandler: NSObject, AgoraRtcEngineDelegate {
    weak var delegate: EventDelegate?
    var tag = ""
    var enableEvent = false
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]didJoinedOfUid (other) uid \(uid) elapsed \(elapsed)ms")
        delegate?.didJoinedOfUid(handler: self, uid: uid, elapsed: elapsed)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]rtcEngine firstRemoteVideoFrameOfUid \(uid) size:\(size)")
        delegate?.firstRemoteVideoFrameOfUid(uid: uid, size: size, elapsed: elapsed)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]error: \(errorCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit,
                   didJoinChannel channel: String,
                   withUid uid: UInt,
                   elapsed: Int) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]didJoinChannel (me) \(channel) with uid \(uid) elapsed \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit,
                   didOfflineOfUid uid: UInt,
                   reason: AgoraUserOfflineReason) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]remote user left: \(uid) reason \(reason)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        guard enableEvent else {
            return
        }
        print("=== [\(tag)]remoteVideoStats \(stats)")
        delegate?.remoteVideoStats(stats: stats)
    }
}
