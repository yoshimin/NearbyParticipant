//
//  Peer.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/22.
//

import UIKit
import NearbyInteraction
import MultipeerConnectivity

struct Peer: Equatable, Hashable {
    let user: User
    let peerId: MCPeerID
    let token: NIDiscoveryToken
}
