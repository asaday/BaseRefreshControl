
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
		lbl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		lbl.textAlignment = .center
		lbl.font = UIFont.systemFont(ofSize:
			11)
		addSubview(lbl)
		
		iv.image = UIImage(named: "ic_autorenew")
		addSubview(iv)
	}
	
	override func layout() {
		lbl.frame = bounds
		iv.frame = CGRect(x: (bounds.width - 24) / 2, y: 0, width: 24, height: 24)
	}
	
	override func progressRefresh(_ progress: CGFloat) {
		lbl.text = "progress \(Int(progress * 100))%"
		let angle: CGFloat = -progress * CGFloat(M_PI)
		iv.transform = CGAffineTransform(rotationAngle: angle)
	}
	
	override func willStartRefresh() {
		lbl.text = "refreshing"
		iv.transform = CGAffineTransform.identity
		let a = CABasicAnimation(keyPath: "transform.rotation.z")
		a.toValue = M_PI * 2
		a.duration = 1
		a.isCumulative = true
		a.repeatCount = .infinity
		iv.layer.add(a, forKey: "rotate")
		
	}
	
	override func willEndRefresh() {
		lbl.text = "done"
		iv.layer.removeAnimation(forKey: "rotate")
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	let table = UITableView(frame: .zero, style: .plain)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		table.frame = view.bounds
		table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		table.dataSource = self
		table.delegate = self
		table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		view.addSubview(table)
		
		let refresh = BRCSRefreshControl() //MyRefreshControl()
		refresh.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
		table.addSubview(refresh)

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(aaa))
	}
	
	func aaa(){
		let a = BRCSActivityIndicatorView(activityIndicatorStyle: .gray)
		a.center = view.center
		view.addSubview(a)
		a.startAnimating()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1000
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = "row \(indexPath.row)"
		return cell
	}
	
	func doRefresh(refresh: BaseRefreshControl) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
			refresh.endRefreshing()
		}
	}
}

