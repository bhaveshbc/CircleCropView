//
//  ViewController.swift
//  CropViewExample
//
//  Created by Bhavesh Chaudhari on 07/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import CIrcleCropView

class ViewController: UIViewController {
    var imagePicker: ImagePicker!
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true
    }

    @IBAction func selectImageClick(sender: UIButton) {
        self.openCameraActionSheet { cameraState in
            if let state = cameraState {
                self.openImagePicker(with: state)
            }
        }
    }

    private func presentCropViewController(with Image: UIImage) {
        let cropViewController = CropViewController(image: Image) { [unowned self] croppedImage in
            self.imageView.image = croppedImage
        }
        self.present(cropViewController, animated: true, completion: nil)
    }

    /// function responsible for open ImagePicker with selected action for camera state
    /// - Parameter state: camera state enum contain two case 1. camera 2.gallary
    private func openImagePicker(with state: CameraState) {
        self.imagePicker = ImagePicker(fromController: self, state: state, compltionClouser: { [unowned self] pickupResult in
            switch pickupResult {
            case .success(let selectedImage):
                DispatchQueue.main.async {
                    self.presentCropViewController(with: selectedImage)
                }
            case .error(let message):
                self.presentAlertMessage(message: message)
            }
        })
    }
}

extension ViewController {
    func openCameraActionSheet(compltion:@escaping (CameraState?) -> Void) {
        let cameraActionSheet = UIAlertController(title: "", message: "Select Option", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            compltion(.camera)
        }

        let gallaryAction = UIAlertAction(title: "Gallary", style: .default) { _ in
            compltion(.gallary)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            compltion(nil)
        }
        cameraActionSheet.addAction(cameraAction)
        cameraActionSheet.addAction(gallaryAction)
        cameraActionSheet.addAction(cancelAction)

        if let popoverController = cameraActionSheet.popoverPresentationController {
           popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
        }

        self.present(cameraActionSheet, animated: true, completion: nil)
    }

    /// The Function present Alert Controller with given message,Title and clouser.
    /// - Parameter title: title for alert Controller
    /// - Parameter message: message for alert Controller
    /// - Parameter okclick: Clouser for okay button
    func presentAlertMessage(title: String = "Alert", message: String, okclick: (() -> Void)? = nil) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
                if okclick != nil {
                    okclick!()
                }
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true) {
            }
        }
}

