//
//  User.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import UIKit

struct User: Equatable, Hashable {
    let name: String
    let biography: String
    let image: UIImage
    let tags: [String]
}
