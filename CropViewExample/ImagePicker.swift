//
//  ImagePicker.swift
//  CropViewExample
//
//  Created by Bhavesh Chaudhari on 08/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices
import Photos

enum PickerResult {
    case success(image: UIImage)
    case error(message: String)
}

enum CameraState {
    case gallary
    case camera
}

typealias ImagecompltionClouser = (PickerResult) -> Void

class ImagePicker: NSObject {
    private  var imagepicker = UIImagePickerController()
    private var resultClouser: ImagecompltionClouser!
    private var fromViewController: UIViewController!
    var cameraState: CameraState!

    enum PermissionState {
        case sucess
        case error(error: String)
    }

    init(fromController: UIViewController, state: CameraState, compltionClouser: @escaping ImagecompltionClouser) {
        super.init()
        imagepicker.delegate = self
        self.fromViewController = fromController
        self.resultClouser = compltionClouser
        self.cameraState = state
        decideSelection(state: state)
    }

    private func decideSelection(state: CameraState) {
        switch state {
        case .camera:
            checkCameraPermission { permissionState in
                switch permissionState {
                case .sucess :
                    DispatchQueue.main.async {
                        self.openImagePicker(with: .camera)
                    }
                case .error(let message):
                    self.resultClouser(.error(message: message))
                }
            }
        case .gallary :
            checkGallaryPermission { permissionState in
                switch permissionState {
                case .sucess :
                    DispatchQueue.main.async {
                        self.openImagePicker(with: .photoLibrary)
                    }
                case .error(let message):
                    self.resultClouser(.error(message: message))
                }
            }
        }
    }

    private func checkCameraPermission(compltion: @escaping ((PermissionState) -> Void)) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            compltion(.sucess)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool)  in
                if granted {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        compltion(.sucess)
                    } else {
                        compltion(.error(error: "Camera not available"))
                    }
                } else {
                    compltion(.error(error: "enable Camera Permission from the Setting."))
                }
            })
        }
    }

    private func checkGallaryPermission(compltion: @escaping ((PermissionState) -> Void)) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .authorized {
            compltion(.sucess)
        } else {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        compltion(.sucess)
                    } else {
                        compltion(.error(error: "PhotoLibrary not available"))
                    }
                } else {
                    compltion(.error(error: "Photo Library permission not enable"))
                }
            })
        }
    }

    private func openImagePicker(with sourceType: UIImagePickerController.SourceType) {
        imagepicker.sourceType = sourceType
        imagepicker.mediaTypes = [kUTTypeImage as String]
        imagepicker.allowsEditing = false
        self.fromViewController.present(imagepicker, animated: true, completion: nil)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [ UIImagePickerController.InfoKey: Any]) {
        guard var image = info[.originalImage] as? UIImage else {
            return
        }

        if image.size.height > image.size.width {
            if image.size.height > 1000 {
                let newWidth = 1000 * image.size.width / image.size.height
                guard let resizedImage = resizedImage(at: image, for: CGSize(width: newWidth, height: 1000)) else {
                    return
                }
                image = resizedImage
            }
        } else {
            if image.size.width > 1000 {
                let newheigh = 1000 * image.size.height / image.size.width
                guard let resizedImage = resizedImage(at: image, for: CGSize(width: 1000, height: newheigh)) else {
                    return
                }
                image = resizedImage
            }
        }
        self.resultClouser(.success(image: image))
        picker.dismiss(animated: true, completion: nil)
    }

   func resizedImage(at oriznalImage: UIImage, for size: CGSize) -> UIImage? {
       let renderer = UIGraphicsImageRenderer(size: size)
       return renderer.image { _ in
           oriznalImage.draw(in: CGRect(origin: .zero, size: size))
       }
   }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
