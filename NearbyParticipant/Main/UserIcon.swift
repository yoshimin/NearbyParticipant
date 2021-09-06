//
//  UserIcon.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/28.
//

import SwiftUI

struct UserIcon: View {
    let user: User
    let distance: String
    let opacity: Double

    init(_ user: User, distance: Float?) {
        self.user = user
        if let distance = distance {
            self.distance = String(format: "%.1f", distance)+"m"
            self.opacity = 1
        } else {
            self.distance = "-m"
            self.opacity = 0.8
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .center, spacing: 2) {
                UserImage(image: user.image)
                    .frame(width: 70, height: 70)
                Text(user.name)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            Text(distance)
                .foregroundColor(.white)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 1.2)
                .padding(.horizontal, 3)
                .background(Color.blue)
                .clipShape(Capsule())
                .padding(.trailing, -10)
        }
        .padding()
        .opacity(opacity)
    }
}

struct UserIcon_Previews: PreviewProvider {
    static var previews: some View {
        let user = User(
            name: "中野四葉",
            biography: "五つ子の4番目",
            image: UIImage(named: "yotsuba")!,
            tags: ["iOS15","AirTag"]
        )
        UserIcon(user, distance: 0.8313)
            .previewLayout(.fixed(width: 300, height: 300))
    }
}

