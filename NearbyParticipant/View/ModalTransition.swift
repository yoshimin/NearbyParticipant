//
//  ModalTransition.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import SwiftUI

struct ModalTransition {
    var percentage: CGFloat
}

extension ModalTransition: GeometryEffect {
    var animatableData: CGFloat {
        get { percentage }
        set { percentage = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let parcentage = percentage
        let ty = (UIScreen.main.bounds.height - size.height)*0.5*(1-parcentage)
        return ProjectionTransform(
            CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: ty)
        )
    }
}
