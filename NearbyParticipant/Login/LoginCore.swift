//
//  LoginCore.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import UIKit
import ComposableArchitecture

struct LoginState: Equatable {
    var name: String = ""
    var biography: String = ""
    var image: UIImage = UIImage(named: "icon")!
    var tags: String = ""
    var isFormValid: Bool = false
    var isImagePickerPresented: Bool = false
}

enum LoginAction: Equatable {
    case nameChanged(String)
    case biographyChanged(String)
    case imageTapped
    case imageChanged(UIImage)
    case tagsChanged(String)
    case startButtonTapped
    case started(User)
    case setImagePicker(isPresented: Bool)
}

struct LoginEnvironment {
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, env in
    switch (action) {
    case let .nameChanged(name):
        state.name = name
        state.isFormValid = name.count > 0
        return .none

    case let .biographyChanged(biography):
        state.biography = biography
        return .none

    case .imageTapped:
        state.isImagePickerPresented = true
        return .none

    case let .imageChanged(image):
        state.isImagePickerPresented = false
        state.image = image
        return .none

    case let .tagsChanged(tags):
        state.tags = tags
        return .none

    case .startButtonTapped:
        let tags = state.tags.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
        let user = User(name: state.name, biography: state.biography, image: state.image, tags: tags)
        return Effect(value: .started(user))

    case let .started(user):
        return .none

    case .setImagePicker(isPresented: true):
        return .none

    case .setImagePicker(isPresented: false):
        state.isImagePickerPresented = false
        return .none
    }
}
