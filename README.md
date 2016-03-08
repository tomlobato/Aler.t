
Simple Alert Class in Swift 2.

Dependencies:
- FXBlurView for blured overlay.
- Optionally NUI, for styling elements.

Features:
- Callback with user made selection.
- OK and optionally Cancel button.
- NUI classes for styling.
- Overlay with blur and/or partial transparency.

# Install

Just copy Alert.swift to your projet. 

Then add to your Podfile:

```ruby
pod 'NUI'
pod 'FXBlurView'
```

And

```bash
pod install
```

# Usage:

```swift
Aler.t.success("YES!", subTit: "It works.")
```

```swift
Aler.t.confirm("Ugh!", subTit: "something wrong :(", okText: "YES") {
   switch $0 {
   case .Ok:
       print("ok tapped")
   case .Cancel:
       print("cancel tapped")
   }
}
```

```swift
Aler.t.error("Ugh!", subTit: "something wrong :(", overlay: .Transparency) {
   navigationController?.popViewControllerAnimated(true)
}
```

Can be invoked with the helpers .success(), .error(), .confirm(), .warning() or directly with .show():

```swift
func show(title: String! = nil,
              sub: String,
              type: AlertType = .Success,
              okText: String = "OK",
              cancelText: String = "Cancel",
              var overlay: AlertOverlay! = nil,
              callback: AlertReturnBlock! = nil
    ){ ...

```
