//
//  BaseRefreshControl.swift
//  BaseRefreshControl
//

import UIKit

open class BaseRefreshControl: UIControl {

	var parent: UIScrollView?
	open var refreshing: Bool = false
	var orgTopInset: CGFloat = 0
	open var triggerHeight: CGFloat = 120
	open var dispHeight: CGFloat = 64

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
		self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
	}

	public convenience init(target: AnyObject?, action: Selector) {
		self.init(frame: .zero)
		addTarget(target, action: action, for: .valueChanged)
	}

	func insetup() {
		isUserInteractionEnabled = false
		autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
		setup()
		isHidden = true
	}

	override open var frame: CGRect {
		didSet {
			if bounds.size != oldValue.size { layout() }
		}
	}

	override open func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		guard let scr = newSuperview as? UIScrollView else { return }
		scr.addObserver(self, forKeyPath: keyPathContentOffset, options: .new, context: nil)

		frame = CGRect(x: 0, y: scr.contentOffset.y + scr.contentInset.top, width: scr.bounds.width, height: dispHeight)
	}

	override open func removeFromSuperview() {
		superview?.removeObserver(self, forKeyPath: keyPathContentOffset, context: nil)
		super.removeFromSuperview()
	}

	override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath != keyPathContentOffset {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}

		guard let scr = superview as? UIScrollView else { return }
		if frame.height <= 0 { return }

		let offset = scr.contentOffset.y + (refreshing ? orgTopInset : scr.contentInset.top)
		frame.origin.y = offset
		isHidden = !refreshing && (offset > 0 || !scr.isDragging)
		if refreshing { return }

		var progress = -(offset / triggerHeight)
		if progress < 0 { progress = 0 }
		progressRefresh(progress)

		if progress >= 1.0 && !refreshing && !scr.isDragging {
			beginRefreshing()
			sendActions(for: .valueChanged)
		}

		// original refresh is trigged in dragging .. but its confuse scroll
	}

	open func beginRefreshing() {
		if refreshing { return }
		refreshing = true
		isHidden = false

		let scr = superview as? UIScrollView
		orgTopInset = scr?.contentInset.top ?? 0

		willStartRefresh()
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
			self.frame.origin.y = -self.frame.height
			scr?.contentInset.top += self.frame.height
			}, completion: nil)
	}

	open func endRefreshing() {
		if !refreshing { return }
		refreshing = false
		isHidden = true

		let scr = superview as? UIScrollView

		willEndRefresh()
		UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
			scr?.contentInset.top = self.orgTopInset
			}, completion: nil)
	}

	open func setup() { }
	open func layout() { }
	open func progressRefresh(_ progress: CGFloat) { }
	open func willStartRefresh() { }
	open func willEndRefresh() { }
}
