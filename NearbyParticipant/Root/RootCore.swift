//
//  RootCore.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import Foundation
import ComposableArchitecture

struct RootState: Equatable {
    var login: LoginState? = LoginState()
    var main: MainState?
}

enum RootAction: Equatable {
    case login(LoginAction)
    case main(MainAction)
}

struct RootEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let rootReducer = Reducer<RootState, RootAction, RootEnvironment>.combine(
    loginReducer
        .optional()
        .pullback(
            state: \.login,
            action: /RootAction.login,
            environment: { _ in
                LoginEnvironment()
            }
        ),
    mainReducer
        .optional()
        .pullback(
            state: \.main,
            action: /RootAction.main,
            environment: { _ in
                MainEnvironment(mcClient: .live, niClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())
            }
        ),
    Reducer { state, action, _ in
        switch action {
        case let .login(.started(user)):
            state.main = MainState(user: user)
            state.login = nil
            return .none

        case .login:
          return .none

        case .main(.logout):
            state.main = nil
            state.login = LoginState()
            return .none

        case .main:
            return .none
        }
    }
)
