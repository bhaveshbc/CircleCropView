//
//  CircleCropView.swift
//  CIrcleCropView Test
//
//  Created by Bhavesh Chaudhari on 08/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit


public class CircleCropView: UIView {


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.58)
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var circleInset: CGRect {
        let rect = bounds
        let minSize = min(rect.width, rect.height)
        let hole = CGRect(x: (rect.width - minSize) / 2, y: (rect.height - minSize) / 2, width: minSize, height: minSize).insetBy(dx: 15, dy: 15)
        return hole
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        let holeInset = circleInset
        context.addRect(holeInset)
        context.clip()
        context.clear(holeInset)
        let bundel = Bundle(for: CircleCropView.self)

        context.draw(UIImage(named: "WhiteGrid.png",in: bundel,compatibleWith: nil)!.cgImage!, in: holeInset)
        context.setFillColor(UIColor.clear.cgColor)
        context.fill( holeInset)
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokeEllipse(in: holeInset)
        context.restoreGState()
    }
}
