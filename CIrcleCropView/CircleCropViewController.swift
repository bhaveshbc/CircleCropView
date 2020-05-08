//
//  CircleCropViewController.swift
//  CIrcleCropView
//
//  Created by Bhavesh Chaudhari on 08/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

public class CropViewController: UIViewController {

    var image: UIImage
    let imageView: UIImageView
    let scrollView: UIScrollView
    let completion: (UIImage?) -> Void
    private var circleView: CircleCropView?


    var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()

    var okButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        button.setTitle("Crop Image", for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(okClick), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        return button
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 10))
        label.text = "PROFILE PICTURE"
        label.textColor = UIColor.white
        label.backgroundColor  = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

   public init(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        self.image = image
        self.completion = completion
        imageView = UIImageView(image: image)
        scrollView = UIScrollView()
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        circleView = CircleCropView(frame: self.view.bounds)
        view.addSubview(scrollView)
        view.addSubview(circleView!)
        view.addSubview(okButton)
        view.addSubview(backButton)
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        scrollView.delegate = self
        view.backgroundColor = UIColor.white
        scrollView.frame = self.view.frame.inset(by: view.safeAreaInsets)
        circleView?.frame = self.scrollView.frame.inset(by: view.safeAreaInsets)
        addConstraint()
    }

    func addConstraint() {

             NSLayoutConstraint.activate([
                okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -46),
                 okButton.heightAnchor.constraint(equalToConstant: 51),
                 okButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 34),
                 okButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -34)
                 ])

            NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
                backButton.widthAnchor.constraint(equalToConstant: 100),
                backButton.heightAnchor.constraint(equalToConstant: 40),
                backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30)
            ])
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollFrame = scrollView.frame
        let imSize = image.size
        guard let hole = circleView?.circleInset, hole.width > 0 else { return }
        let verticalRatio = hole.height / imSize.height
        let horizontalRatio = hole.width / imSize.width
        scrollView.minimumZoomScale = max(horizontalRatio, verticalRatio)
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = scrollView.minimumZoomScale
        let insetHeight = (scrollFrame.height - hole.height) / 2
        let insetWidth = (scrollFrame.width - hole.width) / 2
        scrollView.contentInset = UIEdgeInsets(top: insetHeight, left: insetWidth, bottom: insetHeight, right: insetWidth)
        okButton.clipsToBounds = true
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func backClick(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func okClick(sender: UIButton) {
        self.cropImage()
    }

    private func cropImage() {
        guard let rect = self.circleView?.circleInset else { return }
               let shift = rect.applying(CGAffineTransform(translationX: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y))
               let scaled = shift.applying(CGAffineTransform(scaleX: 1.0 / self.scrollView.zoomScale, y: 1.0 / self.scrollView.zoomScale))
               let newImage = self.image.imageCropped(toRect: scaled)
               self.completion(newImage)
            self.dismiss(animated: true, completion: nil)
        }
}

extension CropViewController: UIScrollViewDelegate {
    func zoomOut() {
        let newScale = scrollView.zoomScale == scrollView.minimumZoomScale ? 0.5 : scrollView.minimumZoomScale
        scrollView.setZoomScale(newScale, animated: true)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //need empty implementation for zooming
    }
}

extension UIImage {
    func imageCropped(toRect rect: CGRect) -> UIImage {
        let rad: (Double) -> CGFloat = { deg in
            return CGFloat(deg / 180.0 * .pi)
        }
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            let rotation = CGAffineTransform(rotationAngle: rad(90))
            rectTransform = rotation.translatedBy(x: 0, y: -size.height)
        case .right:
            let rotation = CGAffineTransform(rotationAngle: rad(-90))
            rectTransform = rotation.translatedBy(x: -size.width, y: 0)
        case .down:
            let rotation = CGAffineTransform(rotationAngle: rad(-180))
            rectTransform = rotation.translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        let transformedRect = rect.applying(rectTransform)
        let imageRef = cgImage!.cropping(to: transformedRect)!
        let result = UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        print("croped Image width and height = \(result.size)")
        return result
    }
}
