//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Pavel on 2/22/18.
//  Copyright © 2018 itrex. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let stringUrl = bestAttemptContent.userInfo["mp4"] as? String, let url = URL(string: stringUrl) {
                AttachmentDownloader.downloadAttachment(url: url, extension: "mp4", completion: { (path, error) in
                    if let path = path {
                        let attachment = try! UNNotificationAttachment(identifier: "mp4", url: path, options: nil)
                        bestAttemptContent.attachments = [attachment]                        
                    }
                })
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

