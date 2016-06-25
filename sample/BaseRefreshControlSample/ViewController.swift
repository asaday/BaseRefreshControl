//
//  ViewController.swift
//  BaseRefreshControlSample
//
//

import UIKit
import BaseRefreshControl

class MyRefreshControl: BaseRefreshControl {

	let lbl = UILabel(frame: .zero)
	let iv = UIImageView(frame: .zero)

	override func setup() {
		lbl.frame = bounds
		lbl.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		lbl.textAlignment = .Center
		lbl.font = UIFont.systemFontOfSize(11)
		addSubview(lbl)

		iv.image = UIImage(named: "ic_autorenew")
		addSubview(iv)
	}

	override func layout() {
		lbl.frame = bounds
		iv.frame = CGRect(x: (bounds.width - 24) / 2, y: 0, width: 24, height: 24)
	}

	override func progressRefresh(progress: CGFloat) {
		lbl.text = "progress \(Int(progress * 100))%"
		let angle: CGFloat = -progress * CGFloat(M_PI)
		iv.transform = CGAffineTransformMakeRotation(angle)
	}

	override func willStartRefresh() {
		lbl.text = "refreshing"
		iv.transform = CGAffineTransformIdentity
		let a = CABasicAnimation(keyPath: "transform.rotation.z")
		a.toValue = M_PI * 2
		a.duration = 1
		a.cumulative = true
		a.repeatCount = .infinity
		iv.layer.addAnimation(a, forKey: "rotate")

	}

	override func willEndRefresh() {
		lbl.text = "done"
		iv.layer.removeAnimationForKey("rotate")
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let table = UITableView(frame: .zero, style: .Plain)

	override func viewDidLoad() {
		super.viewDidLoad()
		table.frame = view.bounds
		table.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		table.dataSource = self
		table.delegate = self
		table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		view.addSubview(table)

		let refresh = MyRefreshControl()
		refresh.addTarget(self, action: #selector(doRefresh(_:)), forControlEvents: .ValueChanged)
		table.addSubview(refresh)

		//table.addSubview(MyRefreshControl(target: self, action: #selector(doRefresh(_:))))
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1000
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		cell.textLabel?.text = "row \(indexPath.row)"
		return cell
	}

	func doRefresh(refresh: BaseRefreshControl) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
			refresh.endRefreshing()
		}
	}
}

