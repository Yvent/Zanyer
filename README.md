# Zanyer

A Singleton For AVPlayer


## Include
* [Play in the background.](#PlayInTheBackground)

   
* [Event handling under open screen.](#EventHandlingUnderOpenScreen)
   * [play progress](#PlayProgress)
   * [loaded progress](#LoadedProgress)
   * [state change](#StateChange)
   * [play](#Play)
   * [pause](#Pause)
   * [continue](#Continue)
   
* [UI and event handling under lock screen.](#UIAndEventHandlingUnderLockScreen)
   * [command center play](#CommandCenterPlay)
   * [command center next](#CommandCenterNext)
   * [command center prve](#CommandCenterPrve)
   
* The handling of unexpected states.
   * [audio interruption](#AudioInterruption)
   * [audio route change](#AudioRouteChange)
   
* PlayerItem Observer
   * "status"
   * "loadedTimeRanges"
   * "playbackBufferEmpty"
   * "playbackLikelyToKeepUp"
   

<a name="PlayInTheBackground"/>

##  Play in the background

```swift
Zanyer.shared.setSessionActive()
   
}
```

<a name="EventHandlingUnderOpenScreen"/>

##  Event handling under open screen

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

<a name="Pause"/>

####  pause

```swift
Zanyer.shared.pauseMusic()
```

<a name="Continue"/>

####  continue

```swift
Zanyer.shared.continueMusic()
```

<a name="UIAndEventHandlingUnderLockScreen"/>

##  UI and event handling under lock screen

<a name="CommandCenterPlay"/>

####  command center play

```swift
Zanyer.shared.commandCenterPlayBlock = { [weak self] in

}
```

<a name="CommandCenterNext"/>

####  command center next

```swift
Zanyer.shared.commandCenterNextBlock = { [weak self] in

}
```

<a name="CommandCenterPrve"/>

####  command center prve

```swift
Zanyer.shared.commandCenterPrveBlock = { [weak self] in

}
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


