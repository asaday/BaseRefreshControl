//
//  BaseRefreshSample.swift
//  BaseRefreshControl
//

import UIKit

open class BRCSActivityIndicatorView: UIView {
	
	let circle = CALayer()
	let replicatorLayer = CAReplicatorLayer()
	let sz: CGFloat = 20
	
	public convenience init(activityIndicatorStyle style: UIActivityIndicatorViewStyle){
		self.init(frame: CGRect.zero)
	}
	
	public override init(frame: CGRect){
		super.init(frame: frame)
		setup()
	}
	
	required public init?(coder: NSCoder){
		super.init(coder: coder)
		setup()
	}
	
	open var activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray
	open var hidesWhenStopped: Bool = true
	open var color: UIColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1)
	open var isAnimating: Bool = false
	
	func setup() {
		var rc = frame
		rc.size = CGSize(width: sz, height: sz)
		frame = rc
	}
	
	open func startAnimating(){
		replicatorLayer.frame = bounds
		layer.addSublayer(replicatorLayer)
		
		circle.bounds = CGRect(x: 0, y: 0, width: 3, height: 3)
		circle.position = CGPoint(x: 0, y: sz / 2)
		circle.backgroundColor = color.cgColor
		circle.cornerRadius = 1.5
		replicatorLayer.addSublayer(circle)
		
		replicatorLayer.instanceCount = 8
		replicatorLayer.instanceDelay = 0.1
		let angle = (2.0 * M_PI) / Double(replicatorLayer.instanceCount)
		replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
		
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation.toValue = 1.6
		scaleAnimation.duration = 0.4
		scaleAnimation.autoreverses = true
		scaleAnimation.repeatCount = .infinity
		scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		circle.add(scaleAnimation, forKey: "scaleAnimation")
		
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotationAnimation.byValue = 2.0 * M_PI
		rotationAnimation.duration = 1.5// 6.0
		rotationAnimation.repeatCount = .infinity
		rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		replicatorLayer.add(rotationAnimation, forKey: "rotationAnimation")
	}
	
	open func stopAnimating(){
		circle.removeAllAnimations()
		replicatorLayer.removeAllAnimations()
		replicatorLayer.removeFromSuperlayer()
	}
}


open class BRCSRefreshControl : BaseRefreshControl {
	
	open var color: UIColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1)

	let circle = CALayer()
	let replicatorLayer = CAReplicatorLayer()
	let sz: CGFloat = 24

	override open func setup() {
		replicatorLayer.frame = bounds
		layer.addSublayer(replicatorLayer)
		
		circle.bounds = CGRect(x: 0, y: 100, width: 3, height: 3)
		circle.position = center
		circle.backgroundColor = color.cgColor
		circle.cornerRadius = 1.5
		replicatorLayer.addSublayer(circle)
		
		replicatorLayer.instanceCount = 8
		replicatorLayer.instanceDelay = 0.1
		let angle = (2.0 * M_PI) / Double(replicatorLayer.instanceCount)
		replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
	}
	
	override open func progressRefresh(_ progress: CGFloat) {
		let angle: CGFloat = -progress * CGFloat(M_PI) * 2
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		circle.position.x = center.x + sz / 2 + 100 * (1 -  min(progress, 1))
		circle.backgroundColor = color.withAlphaComponent(min(progress, 1)).cgColor
		replicatorLayer.transform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
		CATransaction.commit()
	}
	
	override open func willStartRefresh() {
		
		if #available(iOS 10.0, *) {
			let fbgen = UIImpactFeedbackGenerator(style: .light)
			fbgen.prepare()
			fbgen.impactOccurred()
		}
		
		let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
		scaleAnimation.toValue = 1.75
		scaleAnimation.duration = 0.4
		scaleAnimation.autoreverses = true
		scaleAnimation.repeatCount = .infinity
		scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		circle.add(scaleAnimation, forKey: "scaleAnimation")
		
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotationAnimation.byValue = 2.0 * M_PI
		rotationAnimation.duration = 1.5
		rotationAnimation.repeatCount = .infinity
		rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		replicatorLayer.add(rotationAnimation, forKey: "rotationAnimation")
	}
	
	override open func willEndRefresh() {
		circle.position.x = center.x + 100
	}
	
	override open func didEndRefresh() {
		circle.removeAllAnimations()
		replicatorLayer.removeAllAnimations()
	}
	
}

