//
//  ProfileCore.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import Foundation
import ComposableArchitecture

struct ProfileState: Equatable {
    let user: User
}

enum ProfileAction: Equatable {
    case poke
}

struct ProfileEnvironment {}

let profileReducer = Reducer<ProfileState, ProfileAction, ProfileEnvironment> { state, action, _ in
    switch action {
    case .poke:
        return .none
    }
}
