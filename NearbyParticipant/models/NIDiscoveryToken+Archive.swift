//
//  NIDiscoveryToken+Archive.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import NearbyInteraction

extension NIDiscoveryToken {
    func archive() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true) as Data
    }

    static func unarchive(data: Data) -> NIDiscoveryToken? {
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data)
    }
}
