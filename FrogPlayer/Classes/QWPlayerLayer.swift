//
//  QWPlayerLayer.swift
//  IJKMediaFramework
//
//  Created by 杨凯 on 2021/3/17.
//  Copyright © 2021 bilibili. All rights reserved.
//

// 播放状态
public enum QWPlayerStatus: Int {
    case playing    = 1         //播放
    case resume     = 2         //续播
    case pause      = 3         //暂停
    case stop       = 4         //停止
}

// 网络状态
public enum QWNetworkStatus: Int {
    case great      = 1         //棒极了
    case good       = 2         //很好
    case bad        = 3         //差
    case none       = 4         //没有
}

public protocol QWPlayerLayerDelegate: NSObject {
    func qw_playerNetworkState(_ status: QWNetworkStatus) // 网络加载状态发生变化时
    func qw_playerFirstVideo() // 视频第一帧
    func qw_playerPlayStatus(_ status: QWPlayerStatus) // 视频播放状态改变
    func qw_playerProgress(_ pro: Float) // 播放进度
    func qw_playerBufferProgress(_ pro: Float) // 缓冲进度
    func qw_playerEnd() // 播放结束
    func qw_playerError(_ str: String) // 播放错误
}

public class QWPlayerLayer: NSObject {
    public func sayHi() {
        print("hello world")
    }
}

//public class QWPlayerLayer: NSObject {
//
//    deinit {
//        resetPlayer()
//        stopTimer()
//    }
//
//    @objc public var play: IJKFFMoviePlayerController?
//
//    private var playerUrlStr: String = ""
//
//    private var drmKeyStr: String = ""
//
//    private var playView: UIView?
//
//    private var allDuration: Float = 0.0
//
//    private var timer: Timer?
//
//    public var playerStatus: QWPlayerStatus = .stop
//
//    public var networkStatus: QWNetworkStatus = .none
//
//    public weak var delegate: QWPlayerLayerDelegate?
//
//    lazy var playerOptions: IJKFFOptions? = {
//        let options = IJKFFOptions.byDefault()
//        // 如果使用rtsp协议，可以优先用tcp（默认udp）
//        options?.setPlayerOptionValue("tcp", forKey: "rtsp_transport")
//        // 帧速率（fps）可以改，确认非标准帧率会导致音画不同步，所以只能设定为15或者29.97）
//        options?.setPlayerOptionIntValue(Int64(29.97), forKey: "r")
//        // 设置音量大小，256为标准音量。（要设置成两倍音量时则输入512，依此类推)
//        options?.setPlayerOptionIntValue(256, forKey: "vol")
//        // 是否关闭声音，这里是0，不静音
//        options?.setPlayerOptionValue("0", forKey: "an")
//        /*
//         环路滤波，解码参数:可以设置-16/0/8/16/32/48这几个参数，
//         0:是指开启环路滤波，过滤大部分，但解码开销大
//         48:48基本没有开启环路滤波，清晰度低，解码开销小
//         */
//        options?.setCodecOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_loop_filter")
//        options?.setPlayerOptionIntValue(Int64(IJK_AVDISCARD_DEFAULT.rawValue), forKey: "skip_frame")
//        // 最大fps
//        options?.setPlayerOptionIntValue(30, forKey: "max-fps")
//        // 指定最大宽度
//        options?.setPlayerOptionIntValue(960, forKey: "videotoolbox-max-frame-width")
//        // 自动转屏开关
//        options?.setFormatOptionIntValue(0, forKey: "auto_convert")
//        // 设置播放前的最大探测时间
//        options?.setPlayerOptionIntValue(100, forKey: "analyzemaxduration")
//        // 每处理一个packet之后刷新io上下文
//        options?.setPlayerOptionIntValue(1, forKey: "flush_packets")
//        /*
//         ffmpeg 会使用 avformate_find_stream_info 函数通过读取一定字节的码流来分析码流的基本信息，如编码信息，时长，码率，帧率等等。
//         它由两个参数来控制读取的数据量大小，probesize 和 analyzeduration。
//         probesize 以字节为单位（如下面 1024 * 10 = 10M）,
//         analyzeduration 以秒为单位，但是其内部以微秒为时间单位，如下为 1秒 = 1000000微秒
//         （ probesize 默认为 50M，analyzeduration 默认为 5000000微秒 = 5秒 ）
//         减少 probesize 和 analyzeduration 可以有效地减少 avformate_find_stream_info 函数的耗时，从而加快首开，
//         但是注意不能将这两个参数设置得过小(probesize 最小不能少于32字节),否则会导致读取的数据量过小，从而无法解析出码流的基本信息导致播放失败，
//         只有音频没有视频，或者只有视频而没有音频。
//         */
//        options?.setPlayerOptionIntValue(1024 * 10, forKey: "probesize")
//        // 设置播放前的探测时间 1,达到首屏秒开效果
//        options?.setPlayerOptionIntValue(1, forKey: "analyzeduration")
//        // 精准seek
//        options?.setPlayerOptionIntValue(1, forKey: "enable-accurate-seek")
//        // videoToolBox 解码模式 0:软解、1:硬解
//        options?.setPlayerOptionIntValue(1, forKey: "videotoolbox")
//        // 跳帧处理,放CPU处理较慢时，进行跳帧处理，保证播放流程，画面和声音同步
//        options?.setPlayerOptionIntValue(5, forKey: "framedrop")
//        // 最大缓存大小是3秒，可以依据自己的需求修改
//        options?.setPlayerOptionIntValue(3000, forKey: "max_cached_duration")
//        // 是否限制输入缓冲区大小，1：不限制，通常用于直播视频流实时播放
//        options?.setPlayerOptionIntValue(1, forKey: "infbuf")
//        // 自动暂停，直到读取到足够数量的数据包（packet）才会播放。0 : 禁用、1 : 开启
//        options?.setPlayerOptionIntValue(1, forKey: "packet-buffering")
//        // 重连次数
//        options?.setPlayerOptionIntValue(5, forKey: "reconnect")
//        return options
//    }()
//}
//
////MARK: - 方法处理
//extension QWPlayerLayer {
//    @objc public func qw_creatPlayer(_ urlStr: String, _ drmkey: String, _ view: UIView?) {
//        guard urlStr.count != 0 && drmkey.count != 0 && view != nil else {
//            return
//        }
//        resetPlayer()
//        stopTimer()
//        playerUrlStr = urlStr
//        playView = view
//        drmKeyStr = drmkey
//        play = IJKFFMoviePlayerController(drmContentURL: URL(string: urlStr), with: playerOptions, drmkey: drmkey)
//        play?.shouldAutoplay = true
//        play?.scalingMode = .aspectFit
//        play?.view.frame = view!.bounds
//        view!.insertSubview(play!.view, at: 0)
//        DispatchQueue.main.async(execute: {
//            self.play?.prepareToPlay()
//        })
//        addNotificationsObserver()
//    }
//
//    // 播放
//    @objc public func qw_play() {
//        if play != nil {
//            play?.play()
//        }
//    }
//
//    // 暂停
//    @objc public func qw_pause() {
//        if play != nil {
//            play?.pause()
//        }
//    }
//
//    // 停止
//    @objc public func qw_stop() {
//        if play != nil {
//            play?.stop()
//        }
//    }
//
//    // 重播
//    @objc public func qw_replay() {
//        qw_play()
//    }
//
//    // 释放播放器
//    @objc public func resetPlayer() {
//        if play?.view != nil {
//            play = nil
//            play?.stop()
//            play?.shutdown()
//            play?.view.removeFromSuperview()
//            removeNotificationsObserver()
//        }
//    }
//
//    // 计时
//    func startTimer() {
//        stopTimer()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//        RunLoop.current.add(timer!, forMode: .common)
//    }
//
//    @objc func updateTimer() {
//        if let p = play {
//            if p.isPlaying() {
//                let duration = p.duration // 总时长
//                let curDur = p.currentPlaybackTime // 当前进度
//                let bufDur = p.playableDuration // 缓冲时间
//                if curDur >= duration {
//                    stopTimer()
//                }else {
//                    delegate?.qw_playerProgress(Float(curDur))
//                    if bufDur < duration {
//                        delegate?.qw_playerBufferProgress(Float(bufDur))
//                    }
//                }
//            }
//        }
//    }
//
//    // 停止计时
//    func stopTimer() {
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//    }
//}
//
////MARK: - 方法获取
//extension QWPlayerLayer {
//    /// 设置画面的大小和位置
//    func setupVideoWidget(_ frame: CGRect) {
//        play?.view = frame
//    }
//
//    /// 更改视频的填充模式
//    func setRenderMode(_ model: IJKMPMovieScalingMode) {
//        play?.scalingMode = model
//    }
//    /// 获取当前封面
//    func getCurrentThumImage() {
//        play?.thumbnailImageAtCurrentTime()
//    }
//}
//
////MARK: - 通知处理
//extension QWPlayerLayer {
//    func addNotificationsObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleIJKNotifications), name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleIJKNotifications), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleIJKNotifications), name: .IJKMPMoviePlayerLoadStateDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleIJKNotifications(noti:)), name: .IJKMPMoviePlayerFirstVideoFrameRendered, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleIJKNotifications), name: .IJKMPMoviePlayerPlaybackDidFinish, object: nil)
//    }
//
//    func removeNotificationsObserver() {
//        NotificationCenter.default.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerFirstVideoFrameRendered, object: nil)
//        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: nil)
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc func handleIJKNotifications(noti: Notification) {
//        DispatchQueue.main.async(execute: {
//            if noti.name == .IJKMPMediaPlaybackIsPreparedToPlayDidChange {
//                print("============开始播放调用")
//            }
//
//            if noti.name == .IJKMPMoviePlayerLoadStateDidChange {
//                let loadState = self.play?.loadState.rawValue
//                switch loadState {
//                case 3: //开始播放视频
//                    self.delegate?.qw_playerNetworkState(.good)
//                case 4: //网络不好导致了暂停
//                    self.delegate?.qw_playerNetworkState(.bad)
//                default:
//                    break
//                }
//            }
//
//            if noti.name == Notification.Name.IJKMPMoviePlayerPlaybackStateDidChange {
//                let playbackState = self.play?.playbackState
//                switch playbackState {
//                case .stopped:
//                    self.delegate?.qw_playerPlayStatus(.stop)
//                case .playing:
//                    self.delegate?.qw_playerPlayStatus(.playing)
//                case .paused:
//                    self.delegate?.qw_playerPlayStatus(.pause)
//                case .interrupted: // 中断
//                    break
//                case .seekingForward: // 快进
//                    break
//                case .seekingBackward: // 后台
//                    break
//                default: break
//                }
//            }
//
//            if noti.name == .IJKMPMoviePlayerFirstVideoFrameRendered {
//                self.delegate?.qw_playerFirstVideo()
//                self.startTimer()
//            }
//
//            if noti.name == .IJKMPMoviePlayerPlaybackDidFinish {
//                if self.play?.bufferingProgress == 0 {
//                    self.delegate?.qw_playerError("视频加载失败")
//                    return
//                }
//                let reason = noti.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int
//                switch reason {
//                case 0: // playbackEnded
//                    self.delegate?.qw_playerEnd()
//                case 1: // playbackError
//                    self.qw_replay()
//                case 2: // userExited
//                    self.delegate?.qw_playerError("用户退出播放")
//                default: break
//                }
//            }
//        })
//    }
//}
