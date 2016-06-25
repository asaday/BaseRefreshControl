
# BaseRefreshControl

Base kit to make custom UIRefreshControl.

you can make original refresh animation.

## Requirements

- iOS 8.0+
- Xcode 7+

## Integration

### Cocoapods

you can use Cocoapods install BaseRefreshControl by adding it to your Podfile

```
use_frameworks!
...
pod 'BaseRefreshControl'
...
```

### Carthage

you can use Carthage install BaseRefreshControl by adding it to your Cartfile

```
github "asaday/BaseRefreshControl"
```

## Usage

### make

to use, inherit BaseRefreshControl,and write some code.

example

```
import UIKit
import BaseRefreshControl

class MyRefreshControl: BaseRefreshControl {

	let lbl = UILabel(frame: .zero)

	// initialize, add any control
	override func setup() {
		lbl.frame = bounds
		lbl.textAlignment = .Center
		addSubview(lbl)
	}

	override func layout() {
		lbl.frame = bounds
	}

	// in dragging
	override func progressRefresh(progress: CGFloat) {
		lbl.text = "progress \(Int(progress * 100))%"
	}

	// start refreshing
	override func willStartRefresh() {
		lbl.text = "refreshing"
	}

	// end refreshing
	override func willEndRefresh() {
		lbl.text = "done"
	}
}
```

please see sample/

inherit functions 

```
public func setup()
public func layout()
public func progressRefresh(progress: CGFloat)
public func willStartRefresh()
public func willEndRefresh()
```

### use

to use, nearly same UIRefreshControl like this

```
let refresh = MyRefreshControl()
refresh.addTarget(self, action: #selector(doRefresh(_:)), forControlEvents: .ValueChanged)
table.addSubview(refresh)
```


use functions

```
func endRefreshing()
func beginRefreshing()
var refreshing: Bool { get }
```

tips, convenience init

```
table.addSubview(MyRefreshControl(target: self, action: #selector(doRefresh(_:))))
```


