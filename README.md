# Zanyer

A Singleton For AVPlayer


## Include
* Play in the background.
   
* Event handling under open screen.
   * [play progress](#PlayProgress)
   * [loaded progress](#LoadedProgress)
   * [state change](#StateChange)
   * [play](#Play)
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




<a name="PlayProgress"/>

####  play progress

```swift
Zanyer.shared.playProgressBlock = {[weak self] (progress) in
   
}
```
<a name="LoadedProgress"/>

####  loaded progress

```swift
Zanyer.shared.loadedProgressBlock = {[weak self] (progress) in
         
}
```
<a name="StateChange"/>

####  state change

```swift
Zanyer.shared.onStateChanged = {[weak self] (newState) in
             
        switch newState {
            
         case .running:
            
         case .paused:
              
         case .finished:
                
         }
}
```

<a name="Play"/>

####  play

```swift
Zanyer.shared.playMusic(model: ZanyerModel)
```





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


