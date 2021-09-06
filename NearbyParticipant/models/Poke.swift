//
//  Poke.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import Foundation
import NearbyInteraction

class Poke: NSObject, NSSecureCoding {
    let from: NIDiscoveryToken
    let to: NIDiscoveryToken

    init(from: NIDiscoveryToken, to: NIDiscoveryToken) {
        self.from = from
        self.to = to
    }

    func encode(with coder: NSCoder) {
        coder.encode(from.archive(), forKey: "from")
        coder.encode(to.archive(), forKey: "to")
    }

    required init?(coder: NSCoder) {
        guard
            let fromData = coder.decodeObject(forKey: "from") as? Data,
            let from = NIDiscoveryToken.unarchive(data: fromData),
            let toData = coder.decodeObject(forKey: "to") as? Data,
            let to = NIDiscoveryToken.unarchive(data: toData)
        else { return nil }

        self.from = from
        self.to = to
    }

    static var supportsSecureCoding: Bool { true }
}

extension Poke {
    func archive() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }

    static func unarchive(data: Data) -> Poke? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: Poke.self, from: data)
    }
}
