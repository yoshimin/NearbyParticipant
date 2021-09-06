//
//  NearbyParticipantApp.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import SwiftUI
import ComposableArchitecture

@main
struct NearbyParticipantApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: Store(
                initialState: RootState(),
                reducer: rootReducer.debug(),
                environment: RootEnvironment(
                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                )
            ))
        }
    }
}
