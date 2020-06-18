//
//  ProgressView.swift
//  Secure Kit VPN
//
//  Created by Luchik on 17.01.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import UIKit

class ProgressView: UIView {
    public var onClick: (() -> Void)?
    private var progressLayers: [CAShapeLayer] = []
    private var circleLayer: CAShapeLayer = CAShapeLayer()

    
    enum Status{
        case disconnected, connecting, connected
    }
    
    public var status: Status = .disconnected{
        didSet{
            if status == .disconnected{
                stopRotation()
                progressLayers.forEach({
                     $0.removeFromSuperlayer()
                 })
                self.transform = .identity
                progressLayers = []
                createProgress()
                for i in 1...75{
                    progressLayers[i - 1].strokeColor = UIColor(named: "OrangeColor")!.withAlphaComponent(CGFloat(4/3 * i) / 100.0).cgColor
                }
                //circleLayer.fillColor = UIColor.white.cgColor
            }
            else if status == .connecting{
                startRotation()
            }
            else if status == .connected{
                stopRotation()
                progressLayers.forEach({
                    $0.removeFromSuperlayer()
                })
                progressLayers = []
                //circleLayer.fillColor = UIColor(named: "GreenColor")!.cgColor
                createCircle()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createProgress()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.clickAction))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        createProgress()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.clickAction))
        addGestureRecognizer(gesture)
    }
    
    private func createProgress() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let lineWidth: CGFloat = 1.0
        let radius = (min(bounds.size.width, bounds.size.height) - lineWidth) / 2 - 10.0
        circleLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.strokeColor = UIColor.lightGray.cgColor
        circleLayer.lineWidth = lineWidth
        layer.addSublayer(circleLayer)
        
        
        let step: CGFloat = 0.01
        // - .pi /2 : .pi
        
        for i in 1...75{
            let progressLayer = CAShapeLayer()
            let startAngle: CGFloat = -.pi / 2 + (step * CGFloat(i - 1))
            progressLayer.path = UIBezierPath(arcCenter: center, radius: radius + 4.0, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true).cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = UIColor(named: "OrangeColor")!.withAlphaComponent(CGFloat(4/3 * i) / 100.0).cgColor
            progressLayer.strokeStart = step * CGFloat(i - 1)
            progressLayer.strokeEnd = step * CGFloat(i)
            progressLayer.lineWidth = 8.0
            progressLayer.lineCap = .round
            progressLayers.append(progressLayer)
            layer.addSublayer(progressLayer)
        }
    }
    
    private func createCircle(){
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.size.width, bounds.size.height) - 1.0) / 2 - 10.0
        let progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: center, radius: radius + 4.0, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: true).cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor(named: "GreenColorDark")!.cgColor
        progressLayer.lineWidth = 8.0
        progressLayer.lineCap = .round
        progressLayers.append(progressLayer)
        layer.addSublayer(progressLayer)
    }
    
    @objc private func clickAction(){
        print("Clicked!")
        onClick!()
        /*if isRotating(){
            stopRotation()
        }
        else{
            startRotation()
        }*/
    }
    
    private var rotating: Bool = false
    
    public func isRotating() -> Bool{
        return rotating
    }
    
    public func startRotation(){
        self.rotating = true
        self.rotateView()
    }
    
    public func stopRotation(){
        self.rotating = false
    }
    
    private func rotateView(duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear, .allowUserInteraction], animations: {
            if self.rotating{
                self.transform = self.transform.rotated(by: .pi)
            }
        }) { finished in
            if self.rotating{
                self.rotateView(duration: duration)
            }
            else{
                self.transform = .identity
            }
        }
    }
}
