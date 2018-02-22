//
//  AttachmentDownloader.swift
//  Attachment
//
//  Created by Pavel on 2/11/18.
//  Copyright © 2018 itrex. All rights reserved.
//

import Foundation

class AttachmentDownloader {
    static func downloadAttachment(url: URL, extension: String, completion: ((URL?, Error?) -> ())?) {
        let filename = ProcessInfo.processInfo.globallyUniqueString
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).\(`extension`)")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let _ = try! data?.write(to: path)
            completion?(path, error)
        }
        task.resume()
    }
}
