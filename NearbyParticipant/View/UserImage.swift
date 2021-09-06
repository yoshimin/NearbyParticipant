//
//  UserImage.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/09/04.
//

import SwiftUI

struct UserImage: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white,lineWidth:4).shadow(radius: 10))
    }
}

struct UserImage_Previews: PreviewProvider {
    static var previews: some View {
        UserImage(image: UIImage(named: "yotsuba")!)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
