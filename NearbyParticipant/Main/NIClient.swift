//
//  NIClient.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/03/12.
//

import Foundation
import Combine
import ComposableArchitecture
import NearbyInteraction

struct NIClient {
    var setupSession: (AnyHashable) -> Effect<NIClient.Action, NIClient.Error>
    var run: (NIDiscoveryToken, AnyHashable) -> Void
    var stopSession: (AnyHashable) -> Void

    enum Action: Equatable {
        case send(NIDiscoveryToken)
        case onUpdateNearbyObjects([NINearbyObject])
        case onRemoveNearbyObjects([NINearbyObject])
    }

    enum Error: Swift.Error, Equatable {
    }
}

private var dependencies: [AnyHashable: NIDependencies] = [:]

extension NIClient {
    static let live = NIClient(
        setupSession: { id in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    stopDependencies(id: id)
                }

                let sessionDelegate = SessionDelegate(
                    onUpdate: { subscriber.send(.onUpdateNearbyObjects($0)) },
                    onRemove: { subscriber.send(.onRemoveNearbyObjects($0)) }
                )
                let session = NISession()
                session.delegate = sessionDelegate

                dependencies[id] = NIDependencies(
                    session: session,
                    sessionDelegate: sessionDelegate
                )

                guard let discoveryToken = session.discoveryToken else {
                    return cancellable
                }
                subscriber.send(.send(discoveryToken))

                return cancellable
            }
        },
        run: { discoveryToken, id in
            let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
            let session = dependencies[id]?.session
            session?.run(config)
        },
        stopSession: { id in
            stopDependencies(id: id)
        }
    )
}

private extension NIClient {
    static func stopDependencies(id: AnyHashable) {
        dependencies[id] = nil
    }
}

private struct NIDependencies {
    let session: NISession
    let sessionDelegate: NISessionDelegate
}

private class SessionDelegate: NSObject, NISessionDelegate {
    let onUpdate: ([NINearbyObject]) -> Void
    let onRemove: ([NINearbyObject]) -> Void

    init(
        onUpdate: @escaping ([NINearbyObject]) -> Void,
        onRemove: @escaping ([NINearbyObject]) -> Void
    ) {
        self.onUpdate = onUpdate
        self.onRemove = onRemove
    }

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        onUpdate(nearbyObjects)
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        if reason == .timeout {
            print("session removed by timeout.")

            if let config = session.configuration {
                print("retry session.")
                session.run(config)
                return
            }
        }

        onRemove(nearbyObjects)
    }

    func session(_ session: NISession, didInvalidateWith error: Error) {
        print("session invalidated with error \(error)")
    }
}
