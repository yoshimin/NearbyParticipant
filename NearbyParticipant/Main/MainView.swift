//
//  MainView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {
    let store: Store<MainState, MainAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                CaptureVideoPreview()
                ZStack {
                    Color.clear
                    ZStack {
                        ForEach(viewStore.connectedPeers, id: \.self) { peer in
                            Group {
                                if let nearbyObject = viewStore.nearbyObjects.first(where: {peer.token == $0.peer.token}) {
                                    UserIcon(peer.user, distance: nearbyObject.distance)
                                        .onTapGesture(count: 1, perform: {
                                            viewStore.send(.select(peer))
                                        })
                                        .offset(x: nearbyObject.offset.width, y: nearbyObject.offset.height)
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                .drawingGroup()
                if let peer = viewStore.state.pokedFrom {
                    PokeView(from: peer.user,
                             to: viewStore.state.user,
                             poke: { viewStore.send(.poke(peer)) },
                             close: { viewStore.send(.closePokeView) })
                }
            }
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented:
                    viewStore.binding(
                        get: { $0.isProfilePresented },
                        send: MainAction.setSheet(isPresented:)
                    )
            ) {
                IfLetStore(
                    store.scope(
                        state: { $0.profile },
                        action: MainAction.profile
                    ),
                    then: ProfileView.init(store:)
                )
            }
            .onAppear{ viewStore.send(.onAppear) }
        }
    }
}

private extension NearbyObject {
    var offset: CGSize {
        guard let direction = direction else {
            return .zero
        }
        let x = UIScreen.main.bounds.width * 0.5 * CGFloat(direction.x)
        let y = UIScreen.main.bounds.height * 0.5 * CGFloat(direction.y) * -1
        return CGSize(width: x, height: y)
    }
}
