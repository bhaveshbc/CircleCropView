# CircleCropView



![](/IMG_7664.PNG)

<div>
  <b>CircleCropView Crop Image in Circle Shape.it is used for editing profile picture Image, cropping part of image etc.</b>
  </div>

# Features

* Crop Image by Zoom inside and outside
* Crop Circular portion from Image



Copy and pasting code sucks, even more when you find a bug and have to fix all the apps using it. But is there a way to avoid it?
yes there is, apple intorude feature called # frameworks 

# What is Framework

A framework is a modular and reusable set of code that is used as the building blocks of higher-level pieces of software.

# let's start

Let’s open Xcode and create a new project. Select the iOS tab, scroll down to Framework & Library and select Cocoa Touch Framework.

![Test Image 5](https://miro.medium.com/max/624/1*AWtcOjbkA5nikOnnjQjOiQ.png)

create new swift file and name it circleCropView.select Cocoa Touch Class and then select UIView from the drop down. I’m naming it CircleCropView.

![Test Image 6](https://miro.medium.com/max/624/1*oJZtpa00tbogUvagAGFAww.png)


  class CircleCropView: UIView {
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
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        let holeInset = circleInset
        
        context.addEllipse(in: holeInset);
        context.clip();
        context.clear(holeInset);
        context.draw(UIImage(named: "WhiteGrid.png")!.cgImage!, in: holeInset)
        context.setFillColor( UIColor.clear.cgColor);
        context.fill( holeInset);
        context.setStrokeColor(UIColor.white.cgColor)
        context.strokeEllipse(in: holeInset)
        context.restoreGState()
    }
}





