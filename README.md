# RTCDemo (Instant Calls)
Peer to peer audio/video calls application using WebRTC technology.

<b>iTunes link:</b> [Instant calls on App Store](https://itunes.apple.com/us/app/instant-calls/id1189357287)<br>
<b>iTunes name:</b> Instant Calls<br>
<b>License:</b> MIT

## User Interface

![1](/Screenshots/appstore_screenshot1.jpg?raw=true =320px "1")
![2](/Screenshots/appstore_screenshot2.jpg?raw=true =320px "2")
![3](/Screenshots/appstore_screenshot3.jpg?raw=true =320px "3")
![4](/Screenshots/appstore_screenshot4.jpg?raw=true =320px "4")
![5](/Screenshots/appstore_screenshot5.jpg?raw=true =320px "5")


## Project information:<br>
<b>Swift version:</b> 4.2<br>
<b>Signaling channel:</b> QuickBlox chat API, SendBirdSDK chat API<br>
<b>REST API provider:</b> QuickBlox REST API<br>
<b>REST API provides:</b><br>
User login and registration<br>
Retrieving users in a room<br>
Push Notifications<br>

How to add your custom signalling channel or REST API provider:<br>
1. Implement protocol SignalingChannelProtocol<br>
2. Implement protocol RESTServiceProtocol<br>
3. Initialize your classes in ServicesProvider<br>

Targets information:

1. (QB)RTCDemo_s uses WebRTC.framework and should be used by default

# VIPER Information and implementation

I applied and modified architecture pattern VIPER from Rambler Digital Solutions

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

Unit tests should be run on 64-bit Simulator (example: iPhone 8)
