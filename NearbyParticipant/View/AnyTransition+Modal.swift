//
//  AnyTransition+Modal.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import SwiftUI

extension AnyTransition {
    static var modal: AnyTransition {
        get {
            modifier(
                active: ModalTransition(percentage: 0),
                identity: ModalTransition(percentage: 1)
            )
        }
    }
}
