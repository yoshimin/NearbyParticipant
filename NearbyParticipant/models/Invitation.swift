//
//  Invitation.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/06.
//

import UIKit
import NearbyInteraction

class Invitation: NSObject, NSSecureCoding {
    let name: String
    let biography: String
    let image: UIImage
    let tags: [String]
    let token: NIDiscoveryToken

    init(user: User, token: NIDiscoveryToken) {
        self.name = user.name
        self.biography = user.biography
        self.image = user.image
        self.tags = user.tags
        self.token = token
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(biography, forKey: "biography")
        coder.encode(image.pngData()!, forKey: "image")
        coder.encode(tags.joined(separator:","), forKey: "tags")
        coder.encode(token.archive(), forKey: "token")
    }

    required init?(coder: NSCoder) {
        guard
            let name = coder.decodeObject(forKey: "name") as? String,
            let biography = coder.decodeObject(forKey: "biography") as? String,
            let imageData = coder.decodeObject(forKey: "image") as? Data,
            let image = UIImage.init(data: imageData),
            let tags = coder.decodeObject(forKey: "tags") as? String,
            let tokenData = coder.decodeObject(forKey: "token") as? Data,
            let token = NIDiscoveryToken.unarchive(data: tokenData)
        else { return nil }

        self.name = name
        self.biography = biography
        self.image = image
        self.tags = tags.split(separator: ",").map {String($0)}
        self.token = token
    }

    static var supportsSecureCoding: Bool { true }
}

extension Invitation {
    func archive() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }

    static func unarchive(data: Data) -> Invitation? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: Invitation.self, from: data)
    }
}
