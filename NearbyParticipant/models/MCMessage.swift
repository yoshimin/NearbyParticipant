//
//  MCMessage.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import Foundation

class MCMessage: NSObject, NSSecureCoding {
    enum MessageType: String {
        case invitation
        case poke
    }
    var type: MessageType
    var data: Data?

    init(type: MessageType, data: Data?) {
        self.type = type
        self.data = data
    }

    func encode(with coder: NSCoder) {
        coder.encode(type.rawValue, forKey: "type")
        coder.encode(data, forKey: "data")
    }

    required init?(coder: NSCoder) {
        guard
            let typeString = coder.decodeObject(forKey: "type") as? String,
            let type = MessageType(rawValue: typeString)
        else { return nil }

        self.type = type
        self.data = coder.decodeObject(forKey: "data") as? Data
    }

    static var supportsSecureCoding: Bool { true }
}
