# Zanyer

a singleton for AVPlayer


## Include
* Play in the background.
   
* Event handling under open screen.
   * play progress
   * loaded progress
   * state change
   * play
   * pause
   * continue
   
* UI and event handling under lock screen.
   * command center play
   * command center Next
   * command center Prve
   
* The handling of unexpected states.
   * audio interruption
   * audio route change
   
* PlayerItem Observer
   * "status"
   * "loadedTimeRanges"
   * "playbackBufferEmpty"
   * "playbackLikelyToKeepUp"

## Requirements

Zanyer is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 9.0+




#### Install via Podfile

To integrate Repeat into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby

use_frameworks!

platform :ios, '9.0'

target 'Zanyer-Demo' do

pod 'Zanyer' ,'~> 0.0.3'

end
```


