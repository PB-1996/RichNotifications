//
//  NotificationViewController.swift
//  PushContentExtension
//
//  Created by Pavel on 2/14/18.
//  Copyright © 2018 itrex. All rights reserved.
//

import UIKit
import AVKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    var avPlayerLayer: AVPlayerLayer?
    var attachedlink: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        let openLink = UNNotificationAction(identifier: "OpenLink", title: "Open the link", options: [])
        let videoCategory = UNNotificationCategory(identifier: "VideoCategory", actions: [openLink], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([videoCategory])
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        if let videoLink = content.userInfo["link"] as? String {
            self.attachedlink = URL(string: videoLink)
        }
        if let attachment = content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                let asset = AVAsset(url: attachment.url)
                let item = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: item)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.contentsGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                player.actionAtItemEnd = .none
                playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                self.view.layer.addSublayer(playerLayer)
                self.avPlayerLayer = playerLayer
                attachment.url.stopAccessingSecurityScopedResource()
                NotificationCenter.`default`.addObserver(self,
                                                       selector: #selector(playerItemDidReachEnd(notification:)),
                                                       name: Notification.Name.AVPlayerItemDidPlayToEndTime,
                                                       object: item)
            }
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        self.extensionContext?.mediaPlayingPaused()
        self.avPlayerLayer?.player?.currentItem?.seek(to: kCMTimeZero, completionHandler: nil)
        self.avPlayerLayer?.player?.pause()
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if let attachedlink = self.attachedlink {
            extensionContext?.open(attachedlink, completionHandler: nil)
        }
        completion(.doNotDismiss)
    }
    
    // media play-pause button
    var mediaPlayPauseButtonFrame: CGRect {
        let buttonWidth = 0.1 * self.view.bounds.size.width
        return CGRect(x: 0.66 * buttonWidth, y: self.view.bounds.size.height - 1.66 * buttonWidth, width: buttonWidth, height: buttonWidth)
    }
    var mediaPlayPauseButtonTintColor: UIColor {
        return .white
    }
    var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType {
        return .`default`
    }
    func mediaPlay() {
        self.avPlayerLayer?.player?.play()
    }
    func mediaPause() {
        self.avPlayerLayer?.player?.pause()
    }
    
    deinit {
        NotificationCenter.`default`.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayerLayer?.player?.currentItem)
    }
}
