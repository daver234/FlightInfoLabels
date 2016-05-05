/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
 *
 * modified by Dave Rothschild May 4, 2016
*/

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!
  
  //MARK: view controller methods
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    //set the initial flight data
    self.changeFlightDataTo(londonToParis)
  }
  
  func changeFlightDataTo(data: FlightData) {
    
    //populate the UI with the next flight's data
    summary.text = data.summary
    flightNr.text = data.flightNr
    gateNr.text = data.gateNr
    departingFrom.text = data.departingFrom
    arrivingTo.text = data.arrivingTo
    flightStatus.text = data.flightStatus

    UIView.transitionWithView(snowView, duration: 1.5, options: [.TransitionCrossDissolve], animations: {
      self.snowView.hidden = !data.showWeatherEffects
      }, completion: nil)

    // animate background image
    let overlay = duplicateImageViewFrom(bgImageView, newImageName: data.weatherImageName)
    
    overlay.alpha = 0.0
    overlay.transform = CGAffineTransformMakeScale(1.33, 1.0)
    
    bgImageView.superview!.insertSubview(overlay, aboveSubview: bgImageView)
    
    // duplicate departing airport
    let helperLabel = duplicateLabelFrom(departingFrom)
    departingFrom.superview!.addSubview(helperLabel)
    
    let departingOffset = CGFloat(-80)
    
    departingFrom.center.x += departingOffset
    departingFrom.alpha = 0
    departingFrom.text = data.departingFrom
    
    // create label
    let helperLabelArriving = duplicateLabelFrom(arrivingTo)
    arrivingTo.superview!.addSubview(helperLabelArriving)
    
    // position the helper label 50 points away from the original position, make it transparent and set the text to the destination airport code
    let arrivingOffset = CGFloat(-50)
    self.arrivingTo.center.y += arrivingOffset
    self.arrivingTo.alpha = 0
    self.arrivingTo.text = data.arrivingTo
    
    // kick off animations
    UIView.animateWithDuration(0.5, animations: {
      overlay.alpha = 1.0
      overlay.transform = CGAffineTransformIdentity
        
        self.departingFrom.center.x -= departingOffset
        self.departingFrom.alpha = 1.0
        
        helperLabel.alpha = 0.0
        helperLabel.center.x += departingOffset
        
        // This will move and fade in the original label.
        self.arrivingTo.center.y -= arrivingOffset
        self.arrivingTo.alpha = 1
        helperLabelArriving.alpha = 0.0
        helperLabelArriving.center.y += arrivingOffset
        
    }, completion: {_ in
      self.bgImageView.image = overlay.image
      overlay.removeFromSuperview()
        helperLabel.removeFromSuperview()
        helperLabelArriving.removeFromSuperview()
    })
    
    // schedule next flight
    delay(seconds: 3.0) {
      self.changeFlightDataTo(data.isTakingOff ? parisToRome : londonToParis)
    }
    
  }
}

////////////////////////////////////////
//
//    Starter project code
//
////////////////////////////////////////
extension ViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: CGRectOffset(view.frame, 0, 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
  }
  
  func duplicateImageViewFrom(originalView: UIImageView, newImageName: String) -> UIImageView {
    let duplicate = UIImageView(image: UIImage(named: newImageName)!)
    duplicate.frame = bgImageView.frame
    duplicate.contentMode = bgImageView.contentMode
    duplicate.center = bgImageView.center
    return duplicate
  }
  
  func duplicateLabelFrom(originalLabel: UILabel, newText: String? = nil) -> UILabel {
    let duplicate = UILabel(frame: originalLabel.frame)
    duplicate.text = newText ?? originalLabel.text
    duplicate.font = originalLabel.font
    duplicate.textAlignment = originalLabel.textAlignment
    duplicate.textColor = originalLabel.textColor
    duplicate.backgroundColor = UIColor.clearColor()
    return duplicate
  }
  
}