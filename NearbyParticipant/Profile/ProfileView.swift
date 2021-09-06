//
//  ProfileView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/03.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Image(uiImage: viewStore.state.user.image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white,lineWidth:4).shadow(radius: 10))
                Text(viewStore.state.user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text(viewStore.state.user.biography)
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                    Text(viewStore.state.user.tags.map { "#\($0)" }.joined(separator: " ,"))
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                }
                Button(action: {
                    viewStore.send(.poke)
                }, label: {
                    Text("POKE")
                        .foregroundColor(.white)
                })
                .padding(.vertical, 10)
                .padding(.horizontal, 60)
                .background(Color.blue)
                .cornerRadius(30)
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(
            name: "中野四葉",
            biography: "五つ子の四女。\n元気いっぱいで何事にも全力で立ち向かう。\n断れない性格で良く運動部の助っ人をしている。\n頭に着けたリボンがトレードマーク。",
            image: UIImage(named: "yotsuba")!,
            tags: ["iOS15","AirTag"]
        )
        let store = Store(initialState: ProfileState(user: user),
                          reducer: profileReducer,
                          environment: ProfileEnvironment())
        ProfileView(store: store)
    }
}
