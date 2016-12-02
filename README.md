# RTCDemo
Peer to peer audio/video calls demo with image synchronization using data channel


Targets information

1. RTCDemo_s uses libraries from Scripts/webrtc/lib directory, can be launched without any troubles
2. BuildPeerConnection target used for building WebRTC core stack, first launch takes ~3 hours to download 12-16 Gb of data
3. RTCDemo used to run sample with full webrtc debug mode, BuildPeerConnection must be finished before executing this target


Adding new VIPER module:
```Shell
gem install generamba

cd `folder with Rambafile`

generamba gen VideoCallStory swifty_viper
```
