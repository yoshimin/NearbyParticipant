//
//  LoginView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/15.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    struct ViewState: Equatable {
        var name: String
        var biography: String
        var image: UIImage
        var tags: String
        var isLoginButtonDisabled: Bool
        var loginButtonColor: Color
        var isImagePickerPresented: Bool
    }


    let store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store.scope(state: { $0.view })) { viewStore in
            VStack(spacing: 14) {
                UserImage(image: viewStore.image)
                    .frame(width: 100, height: 100)
                    .onTapGesture(count: 1, perform: {
                        viewStore.send(.imageTapped)
                    })
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text("name")
                            .font(.headline)
                        Text("※")
                            .foregroundColor(.red)
                    }
                    TextField("", text: viewStore.binding(get: { $0.name }, send: LoginAction.nameChanged))
                        .textFieldStyle(DefaultTextFieldStyle())
                        .frame(height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                                .padding(.horizontal, -5)
                        )
                }
                .padding(.horizontal, 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text("biography")
                        .font(.headline)
                    TextEditor(text: viewStore.binding(get: { $0.biography }, send: LoginAction.biographyChanged))
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                                .padding(.horizontal, -2)
                        )
                }
                .padding(.horizontal, 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text("tags")
                        .font(.headline)
                    TextField(" Nearby Interaction, iOS15", text: viewStore.binding(get: { $0.tags }, send: LoginAction.tagsChanged))
                        .textFieldStyle(DefaultTextFieldStyle())
                        .frame(height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                                .padding(.horizontal, -5)
                        )
                }
                .padding(.horizontal, 30)
                Button(action: {
                    viewStore.send(.startButtonTapped)
                }, label: {
                    Text("Start")
                        .foregroundColor(viewStore.loginButtonColor)
                        .frame(width: 200, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewStore.loginButtonColor, lineWidth: 1)
                        )
                })
                .padding(.top, 30)
                .disabled(viewStore.isLoginButtonDisabled)
            }
            .sheet(isPresented:
                    viewStore.binding(
                        get: { $0.isImagePickerPresented },
                        send: LoginAction.setImagePicker(isPresented:)
                    )
            ) {
                ImagePickerView(didFinishPickingMediaWithInfo: {
                    viewStore.send(.imageChanged($0))
                })
            }
        }
    }
}

extension LoginState {
    var view: LoginView.ViewState {
        LoginView.ViewState(
            name: name,
            biography: biography,
            image: image,
            tags: tags,
            isLoginButtonDisabled: !isFormValid,
            loginButtonColor: isFormValid ? .blue : .gray,
            isImagePickerPresented: isImagePickerPresented
        )
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: LoginEnvironment()
        ))
    }
}
