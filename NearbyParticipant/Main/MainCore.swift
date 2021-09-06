//
//  MainCore.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import SwiftUI
import ComposableArchitecture
import MultipeerConnectivity
import NearbyInteraction
import simd

struct MainState: Equatable {
    let user: User
    var connectedPeers: [Peer] = []
    var nearbyObjects: [NearbyObject] = []
    var selectedPeer: Peer?
    var profile: ProfileState?
    var isProfilePresented: Bool { self.selectedPeer != nil }
    var pokedFrom: Peer?
    var isPokeViewPresented: Bool { self.pokedFrom != nil }
}

enum MainAction: Equatable {
    case onAppear
    case mc(Result<MCClient.Action, MCClient.Error>)
    case setupSession(MCPeerID)
    case ni(Result<NIClient.Action, NIClient.Error>)
    case select(Peer)
    case poke(Peer)
    case setSheet(isPresented: Bool)
    case profile(ProfileAction)
    case closePokeView
    case logout
}

struct MainEnvironment {
    let mcClient: MCClient
    let niClient: NIClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let mainReducer = Reducer<MainState, MainAction, MainEnvironment>.combine(
    profileReducer
        .optional()
        .pullback(
            state: \.profile,
            action: /MainAction.profile,
            environment: { _ in ProfileEnvironment() }
        ),
    Reducer<MainState, MainAction, MainEnvironment> { state, action, env in
        struct MCId: Hashable {}
        struct NIId: Hashable {
            let peerId: MCPeerID
        }

        switch action {
        case .onAppear:
            return env.mcClient
                .start(state.user.name, MCId())
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MainAction.mc)

        case let .mc(.success(.onConnect(peerId))):
            return Effect(value: .setupSession(peerId))

        case let .mc(.success(.onDisconnect(peerId))):
            env.niClient.stopSession(NIId(peerId: peerId))
            state.connectedPeers.removeAll(where: { $0.peerId == peerId })
            return .none

        case let .mc(.success(.onReceive(data, peerId))):
            guard let message = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCMessage.self, from: data) else {
                return .none
            }

            switch message.type {
            case .invitation:
                guard let messageData = message.data, let invitation = Invitation.unarchive(data: messageData) else {
                    return .none
                }
                if state.connectedPeers.contains(where: { $0.peerId == peerId }) {
                    return .none
                }

                let user = User(name: invitation.name, biography: invitation.biography, image: invitation.image, tags: invitation.tags)
                let peer = Peer(user: user, peerId: peerId, token: invitation.token)
                env.niClient.run(peer.token, NIId(peerId: peerId))
                state.connectedPeers.append(peer)
            case .poke:
                state.pokedFrom = state.connectedPeers.first(where: { $0.peerId == peerId })
            }
            return .none

        case .mc(.failure(_)):
            return .none

        case let .setupSession(peerId):
            return env.niClient
                .setupSession(NIId(peerId: peerId))
                .receive(on: env.mainQueue)
                .catchToEffect()
                .map(MainAction.ni)

        case let .ni(.success(.send(discoveryToken))):
            guard let invitation = Invitation(user: state.user, token: discoveryToken).archive(),
                  let data = try? NSKeyedArchiver.archivedData(withRootObject: MCMessage(type: .invitation, data: invitation), requiringSecureCoding: true) else {
                return .none
            }

            env.mcClient.send(data, MCId())
            return .none

        case let .ni(.success(.onUpdateNearbyObjects(objects))):
            var nearbyObjects: [NearbyObject] = []
            state.connectedPeers.forEach { peer in
                let nearbyObject: NearbyObject
                if let object = objects.first(where: { $0.discoveryToken == peer.token }) {
                    if let existing = state.nearbyObjects.first(where: { $0.peer.token == peer.token }), object.direction == nil {
                        nearbyObject = NearbyObject(peer: peer, distance: object.distance, direction: existing.direction)
                    } else {
                        nearbyObject = NearbyObject(peer: peer, distance: object.distance, direction: object.direction)
                    }
                } else {
                    if let existing = state.nearbyObjects.first(where: { $0.peer.token == peer.token }) {
                        nearbyObject = existing
                    } else {
                        nearbyObject = NearbyObject(peer: peer, distance: nil, direction: nil)
                    }
                }
                nearbyObjects.append(nearbyObject)
            }
            state.nearbyObjects = nearbyObjects
            return .none

        case let .ni(.success(.onRemoveNearbyObjects(objects))):
            objects.forEach { nearbyObject in
                state.nearbyObjects.removeAll(where: { $0.peer.token == nearbyObject.discoveryToken })
            }
            return .none

        case .ni(.failure(_)):
            return .none

        case let .select(peer):
            state.selectedPeer = peer
            state.profile = ProfileState(user: peer.user)
            return .none

        case .setSheet(isPresented: true):
            return .none

        case .setSheet(isPresented: false):
            state.selectedPeer = nil
            return .none

        case .profile(.poke):
            guard let peer = state.selectedPeer else {
                return .none
            }
            state.selectedPeer = nil
            return Effect(value: .poke(peer))

        case let .poke(peer):
            if let message = try? NSKeyedArchiver.archivedData(withRootObject: MCMessage(type: .poke, data: nil), requiringSecureCoding: true) {
                env.mcClient.send(message, MCId())
            }
            state.pokedFrom = nil
            return .none

        case .closePokeView:
            state.pokedFrom = nil
            return .none

        case .logout:
            return .none
        }
    }
)
