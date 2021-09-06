//
//  PokeView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import SwiftUI

struct PokeView: View {
    let from: User
    let to: User

    let poke: (() -> ())
    let close: (() -> ())

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: -10) {
                HStack {
                    Spacer()
                    Button(action: {
                        close()
                    }){
                        Image("close")
                    }
                }
                .padding(.horizontal)
                HStack(spacing: 10) {
                    VStack {
                        UserImage(image: from.image)
                            .frame(width: 60, height: 60)
                    }
                    Image("poke")
                    VStack {
                        UserImage(image: to.image)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            Text("\(from.name)さんにPOKEされました")
                .font(.headline)
                .foregroundColor(.black)
            Button(action: {
                poke()
            }, label: {
                Text("POKEを返す")
                    .foregroundColor(.white)
            })
            .frame(width: 180, height: 40)
            .background(Color.blue)
            .cornerRadius(20)
        }
        .frame(width: 300, height: 220)
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct PockView_Previews: PreviewProvider {
    static var previews: some View {
        let from = User(
            name: "中野四葉",
            biography: "五つ子の四女。\n元気いっぱいで何事にも全力で立ち向かう。\n断れない性格で良く運動部の助っ人をしている。\n頭に着けたリボンがトレードマーク。",
            image: UIImage(named: "yotsuba")!,
            tags: ["iOS15","AirTag"]
        )
        let to = User(
            name: "中野三玖",
            biography: "五つ子の三女。\nミステリアスで大人しい性格だが、\n内に秘めた思いを持っている。\n他の姉妹の変装が得意で、\nたまに他の姉妹のフリを頼まれる。\n戦国武将が好きな歴女。",
            image: UIImage(named: "miku")!,
            tags: ["iOS15","AirTag"]
        )
        PokeView(from: from, to: to, poke: {}, close: {})
            .previewLayout(.fixed(width: 300, height: 220))
    }
}
