# RTCDemo (Instant Calls)
Peer to peer audio/video calls application using WebRTC technology.

<b>iTunes link:</b> [Instant calls on App Store](https://itunes.apple.com/us/app/instant-calls/id1189357287)<br>
<b>iTunes name:</b> Instant Calls<br>
<b>License:</b> MIT

## Project information:<br>
<b>Swift version:</b> 2.3 (support for 3.0 will be added later)<br>
<b>Signaling channel:</b> QuickBlox chat API<br>
<b>REST API provider:</b> QuickBlox REST API<br>

How to add your custom signalling channel or REST API provider:<br>
1. Implement protocol SignalingChannelProtocol<br>
2. Implement protocol RESTServiceProtocol<br>
3. Initialize your classes in ServicesProvider<br>

Targets information:

1. RTCDemo_s uses WebRTC.framework from Scripts/webrtc/lib directory, should be used by default
2. BuildPeerConnection target used for building WebRTC core stack, first launch takes ~3 hours to download 12-16 Gb of data.<br>
<font color="red">Currently the target is not supported because of updated WebRTC project format.</font>
3. RTCDemo used to run a sample with full webrtc debug mode, BuildPeerConnection must be finished before executing this target.<br>
<font color="red">Currently the target is not supported because of updated WebRTC project format.</font>

Latest supported WebRTC revision(commit) for BuildPeerConnection and RTCDemo is 43166b8adf749c6672eca0cd4a39399cf27d4761 (you can specify this in BuildPeerConnection arguments).

# BuildPeerConnection target

Includes arguments where current WebRTC revision is specified.<br>
Downloads specified revision into Scripts/webrtc folder
# VIPER Information and implementation

I applied and modified the pattern from Rambler Digital Solutions

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

# Tests #

Unit tests should be run on 64-bit Simulator (example: iPhone 5s)
