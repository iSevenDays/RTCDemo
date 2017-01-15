# RTCDemo
Peer to peer audio/video calls demo with image synchronization using data channel.


Targets information:

1. RTCDemo_s uses libraries from Scripts/webrtc/lib directory, can be launched without any troubles
2. BuildPeerConnection target used for building WebRTC core stack, first launch takes ~3 hours to download 12-16 Gb of data
3. RTCDemo used to run a sample with full webrtc debug mode, BuildPeerConnection must be finished before executing this target

# VIPER Information and implementation

I applied and modified this pattern from Rambler Digital Solutions

Adding new VIPER module:

```Shell
gem install generamba

cd `folder with Rambafile`

generamba gen VideoCallStory swifty_viper
```

VIPER integration tips:

Projects uses generamba `swifty_viper` template with some [modifications]([https://github.com/rambler-digital-solutions/The-Book-of-VIPER/issues/21])


```Shell
generamba gen VideoCallStory rviper_controller
```

To correctly route one module to another (performSegue) we should modify the template ():

1. ViewController output must be marked with ```@objc``` 
2. ViewOutput must be marked with ```@objc``` 
2. Presenter must be marked with ```@objc``` and inherit from NSObject
3. In your ViewController storyboard create `Object`, set custom class to `YourStoryClassModuleInitializer`
4. Connect ViewController with `Object` from step 3 (`Object` must have viewController outlet available)