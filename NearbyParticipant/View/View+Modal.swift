//
//  View+Modal.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import SwiftUI

extension View {
    func modal<Destination: View>(
        isPresented: Binding<Bool>,
        view: @escaping () -> Destination
    ) -> some View {
        modifier(Modal(isPresented: isPresented, view: view))
    }
}

struct Modal<Destination>: ViewModifier where Destination: View {
    @Binding var isPresented: Bool

    var view: () -> Destination

    func body(content: Content) -> some View {
        ZStack {
            content
            modal()
        }
    }

    private func modal() -> some View {
        Group {
            if isPresented {
                view()
                    .transition(.modal)
            } else {
                EmptyView()
            }
        }
    }
}
