//
//  NearbyObject.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/22.
//

import Foundation
import simd

struct NearbyObject: Equatable, Hashable {
    let peer: Peer
    let distance: Float?
    let direction: simd_float3?
}
