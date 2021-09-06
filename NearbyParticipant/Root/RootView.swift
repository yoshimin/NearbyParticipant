//
//  RootView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: Store<RootState, RootAction>

    @ViewBuilder var body: some View {
        IfLetStore(
            store.scope(
                state: { $0.login },
                action: RootAction.login
            )
        ) { store in
            LoginView(store: store)
        }

        IfLetStore(
            store.scope(
                state: { $0.main },
                action: RootAction.main
            )
        ) { store in
            MainView(store: store)
        }
    }
}
