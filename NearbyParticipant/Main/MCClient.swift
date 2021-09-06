//
//  MCClient.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/03/11.
//

import Foundation
import MultipeerConnectivity
import Combine
import ComposableArchitecture

struct MCClient {
    static private let appId = "com.sample.NearbyParticipant"
    static private let serviceType = "ni-app"

    var start: (String, AnyHashable) -> Effect<MCClient.Action, MCClient.Error>
    var connectedPeers: (AnyHashable) -> [MCPeerID]
    var send: (Data, MCPeerID?, AnyHashable) -> Void
    var stop: (AnyHashable) -> Effect<Never, Never>

    enum Action: Equatable {
        case onConnect(MCPeerID)
        case onDisconnect(MCPeerID)
        case onReceive(Data, MCPeerID)
    }
    
    enum Error: Swift.Error, Equatable {
    }
}

private var dependencies: [AnyHashable: MCDependencies] = [:]

extension MCClient {
    static let live = MCClient(
        start: { displayName, id in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    stopDependencies(id: id)
                }

                let peerID = MCPeerID(displayName: displayName)

                let sessionDelegate = SessionDelegate(
                    onConnect: { peerID in
                        subscriber.send(.onConnect(peerID))
                    },
                    onDisconnect: { peerID in
                        subscriber.send(.onDisconnect(peerID))
                    },
                    onReceive: { data, peerID in
                        subscriber.send(.onReceive(data, peerID))
                    })
                let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
                session.delegate = sessionDelegate

                let advertiserDelegate = NearbyServiceAdvertiserDelegate(session: session)
                // MEMO: serviceType needs to be 15 characters or fewer
                let advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["appId": appId], serviceType: serviceType)
                advertiser.delegate = advertiserDelegate

                let browserDelegate = NearbyServiceBrowserDelegate(appId: appId, session: session)
                let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
                browser.delegate = browserDelegate

                dependencies[id] = MCDependencies(
                    session: session,
                    sessionDelegate: sessionDelegate,
                    advertiser: advertiser,
                    advertiserDelegate: advertiserDelegate,
                    browser: browser,
                    browserDelegate: browserDelegate,
                    subscriber: subscriber
                )

                advertiser.startAdvertisingPeer()
                browser.startBrowsingForPeers()

                return cancellable
            }
            .cancellable(id: id)
        },
        connectedPeers: { id in
            return dependencies[id]?.session.connectedPeers ?? []
        },
        send: { data, peerId, id in
            guard let session = dependencies[id]?.session else { return }
            send(session: session, data: data, to: peerId)
        },
        stop: { id in
            .fireAndForget {
                stopDependencies(id: id)
            }
        }
    )
}

private extension MCClient {
    static func send(session: MCSession, data: Data, to peerId: MCPeerID?) {
        do {
            try session.send(data, toPeers: peerId == nil ? session.connectedPeers : [peerId!], with: .reliable)
        } catch let error {
            print("failed to send data: \(error)")
        }
    }

    static func stopDependencies(id: AnyHashable) {
        dependencies[id]?.stop()
        dependencies[id] = nil
    }
}

private struct MCDependencies {
    let session: MCSession
    let sessionDelegate: MCSessionDelegate
    let advertiser: MCNearbyServiceAdvertiser
    let advertiserDelegate: MCNearbyServiceAdvertiserDelegate
    let browser: MCNearbyServiceBrowser
    let browserDelegate: MCNearbyServiceBrowserDelegate
    let subscriber: Effect<MCClient.Action, MCClient.Error>.Subscriber

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        subscriber.send(completion: .finished)
    }
}

private class SessionDelegate: NSObject, MCSessionDelegate {
    let onConnect: (MCPeerID) -> Void
    let onDisconnect: (MCPeerID) -> Void
    let onReceive: (Data, MCPeerID) -> Void

    init(
        onConnect: @escaping (MCPeerID) -> Void,
        onDisconnect: @escaping (MCPeerID) -> Void,
        onReceive: @escaping (Data, MCPeerID) -> Void
    ) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onReceive = onReceive
        super.init()
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            onConnect(peerID)
        case .connecting:
            break
        case .notConnected:
            onDisconnect(peerID)
        @unknown default:
            fatalError()
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        onReceive(data, peerID)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // noop
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // noop
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // noop
    }


}

private class NearbyServiceAdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate {
    let session: MCSession
    init(session: MCSession) {
        self.session = session
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("accept invitation from \(peerID.displayName)")
        invitationHandler(true, session)
    }
}

private class NearbyServiceBrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    let appId: String
    let session: MCSession
    init(appId: String, session: MCSession) {
        self.appId = appId
        self.session = session
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard appId == info?["appId"] else { return }
        print("invite \(peerID.displayName) to \(session.myPeerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost \(peerID.displayName)")
    }
}
