//
//  ImagePickerView.swift
//  NearbyParticipant
//
//  Created by Shingai Yoshimi on 2021/08/16.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController

    let didFinishPickingMediaWithInfo: ((UIImage) -> ())

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let didFinishPickingMediaWithInfo: ((UIImage) -> ())

        init(_ didFinishPickingMediaWithInfo: @escaping ((UIImage) -> ())) {
            self.didFinishPickingMediaWithInfo = didFinishPickingMediaWithInfo
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.editedImage] as? UIImage else { return }
            didFinishPickingMediaWithInfo(image)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(didFinishPickingMediaWithInfo)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.allowsEditing = true
        return imagePickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }
}
