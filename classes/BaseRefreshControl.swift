//
//  BaseRefreshControl.swift
//  BaseRefreshControl
//

import UIKit

public class BaseRefreshControl: UIControl {

	var parent: UIScrollView?
	public var refreshing: Bool = false
	var orgTopInset: CGFloat = 0
	public var triggerHeight: CGFloat = 120
	public var dispHeight: CGFloat = 64

	let keyPathContentOffset = "contentOffset"

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		insetup()
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		insetup()
	}

	public convenience init() {
		self.init(frame: .zero)
	}

	public convenience init(target: AnyObject?, action: Selector) {
		self.init(frame: .zero)
		addTarget(target, action: action, forControlEvents: .ValueChanged)
	}

	func insetup() {
		userInteractionEnabled = false
		autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
		setup()
		hidden = true
	}

	override public var frame: CGRect {
		didSet {
			if bounds.size != oldValue.size { layout() }
		}
	}

	override public func willMoveToSuperview(newSuperview: UIView?) {
		super.willMoveToSuperview(newSuperview)
		guard let scr = newSuperview as? UIScrollView else { return }
		scr.addObserver(self, forKeyPath: keyPathContentOffset, options: .New, context: nil)

		frame = CGRect(x: 0, y: scr.contentOffset.y + scr.contentInset.top, width: scr.bounds.width, height: dispHeight)
	}

	override public func removeFromSuperview() {
		superview?.removeObserver(self, forKeyPath: keyPathContentOffset, context: nil)
		super.removeFromSuperview()
	}

	override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath != keyPathContentOffset {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
			return
		}

		guard let scr = superview as? UIScrollView else { return }
		if frame.height <= 0 { return }

		let offset = scr.contentOffset.y + (refreshing ? orgTopInset : scr.contentInset.top)
		frame.origin.y = offset
		hidden = !refreshing && (offset > 0 || !scr.dragging)
		if refreshing { return }

		var progress = -(offset / triggerHeight)
		if progress < 0 { progress = 0 }
		progressRefresh(progress)

		if progress >= 1.0 && !refreshing && !scr.dragging {
			beginRefreshing()
			sendActionsForControlEvents(.ValueChanged)
		}

		// original refresh is trigged in dragging .. but its confuse scroll
	}

	public func beginRefreshing() {
		if refreshing { return }
		refreshing = true
		hidden = false

		let scr = superview as? UIScrollView
		orgTopInset = scr?.contentInset.top ?? 0

		willStartRefresh()
		UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
			self.frame.origin.y = -self.frame.height
			scr?.contentInset.top += self.frame.height
			}, completion: nil)
	}

	public func endRefreshing() {
		if !refreshing { return }
		refreshing = false
		hidden = true

		let scr = superview as? UIScrollView

		willEndRefresh()
		UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
			scr?.contentInset.top = self.orgTopInset
			}, completion: nil)
	}

	public func setup() { }
	public func layout() { }
	public func progressRefresh(progress: CGFloat) { }
	public func willStartRefresh() { }
	public func willEndRefresh() { }
}