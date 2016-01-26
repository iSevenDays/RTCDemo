//
//  quickblox_auido_device_ios_not_implemented.cpp
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 04/01/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#include "quickblox_audio_device_ios.h"
#include "webrtc/base/checks.h"
#include "webrtc/base/logging.h"

namespace webrtc {
    
    int32_t QBAudioDeviceIOS::PlayoutBuffer(webrtc::AudioDeviceModule::BufferType& type,
                                            uint16_t& sizeMS) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::ActiveAudioLayer(webrtc::AudioDeviceModule::AudioLayer& audioLayer) const {
        
        //            audioLayer = webrtc::AudioDeviceModule::kPlatformDefaultAudio;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::ResetAudioDevice() {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int16_t QBAudioDeviceIOS::PlayoutDevices() {
        // TODO(henrika): improve.
        LOG_F(LS_WARNING) << "Not implemented";
        return (int16_t)1;
    }
    
    int16_t QBAudioDeviceIOS::RecordingDevices() {
        // TODO(henrika): improve.
        LOG_F(LS_WARNING) << "Not implemented";
        return (int16_t)1;
    }
    
    int32_t QBAudioDeviceIOS::InitSpeaker() {
        return 0;
    }
    
    bool QBAudioDeviceIOS::SpeakerIsInitialized() const {
        return true;
    }
    
    int32_t QBAudioDeviceIOS::SpeakerVolumeIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetSpeakerVolume(uint32_t volume) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SpeakerVolume(uint32_t& volume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SetWaveOutVolume(uint16_t, uint16_t) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::WaveOutVolume(uint16_t&, uint16_t&) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MaxSpeakerVolume(uint32_t& maxVolume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MinSpeakerVolume(uint32_t& minVolume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SpeakerVolumeStepSize(uint16_t& stepSize) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SpeakerMuteIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetSpeakerMute(bool enable) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SpeakerMute(bool& enabled) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SetPlayoutDevice(uint16_t index) {
        LOG_F(LS_WARNING) << "Not implemented";
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetPlayoutDevice(webrtc::AudioDeviceModule::WindowsDeviceType) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    bool QBAudioDeviceIOS::PlayoutWarning() const {
        return false;
    }
    
    bool QBAudioDeviceIOS::PlayoutError() const {
        return false;
    }
    
    bool QBAudioDeviceIOS::RecordingWarning() const {
        return false;
    }
    
    bool QBAudioDeviceIOS::RecordingError() const {
        return false;
    }
    
    int32_t QBAudioDeviceIOS::InitMicrophone() {
        return 0;
    }
    
    bool QBAudioDeviceIOS::MicrophoneIsInitialized() const {
        return true;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneMuteIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetMicrophoneMute(bool enable) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneMute(bool& enabled) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneBoostIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetMicrophoneBoost(bool enable) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneBoost(bool& enabled) const {
        enabled = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::StereoRecordingIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetStereoRecording(bool enable) {
        LOG_F(LS_WARNING) << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::StereoRecording(bool& enabled) const {
        enabled = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::StereoPlayoutIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetStereoPlayout(bool enable) {
        LOG_F(LS_WARNING) << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::StereoPlayout(bool& enabled) const {
        enabled = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetAGC(bool enable) {
        if (enable) {
            RTC_NOTREACHED() << "Should never be called";
        }
        return -1;
    }
    
    bool QBAudioDeviceIOS::AGC() const {
        return false;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneVolumeIsAvailable(bool& available) {
        available = false;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetMicrophoneVolume(uint32_t volume) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneVolume(uint32_t& volume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MaxMicrophoneVolume(uint32_t& maxVolume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MinMicrophoneVolume(uint32_t& minVolume) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::MicrophoneVolumeStepSize(uint16_t& stepSize) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::PlayoutDeviceName(uint16_t index,
                                                char name[webrtc::kAdmMaxDeviceNameSize],
                                                char guid[webrtc::kAdmMaxGuidSize]) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::RecordingDeviceName(uint16_t index,
                                                  char name[webrtc::kAdmMaxDeviceNameSize],
                                                  char guid[webrtc::kAdmMaxGuidSize]) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::SetRecordingDevice(uint16_t index) {
        LOG_F(LS_WARNING) << "Not implemented";
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetRecordingDevice(
                                                 webrtc::AudioDeviceModule::WindowsDeviceType) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::PlayoutIsAvailable(bool& available) {
        available = true;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::RecordingIsAvailable(bool& available) {
        available = true;
        return 0;
    }
    
    int32_t QBAudioDeviceIOS::SetPlayoutBuffer(
                                               const webrtc::AudioDeviceModule::BufferType type,
                                               uint16_t sizeMS) {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
    
    int32_t QBAudioDeviceIOS::CPULoad(uint16_t&) const {
        RTC_NOTREACHED() << "Not implemented";
        return -1;
    }
}