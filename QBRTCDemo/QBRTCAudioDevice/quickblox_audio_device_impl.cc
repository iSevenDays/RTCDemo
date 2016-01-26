//
//  quickblox_audio_device_impl.cc
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 05/01/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#include "quickblox_audio_device_impl.h"

#include "webrtc/common_audio/signal_processing/include/signal_processing_library.h"
#include "webrtc/modules/audio_device/audio_device_config.h"
#include "webrtc/system_wrappers/include/ref_count.h"
#include "webrtc/system_wrappers/include/tick_util.h"

#include <assert.h>
#include <string.h>
//IOS
#include "quickblox_audio_device_ios.h"

#include "webrtc/modules/audio_device/dummy/audio_device_dummy.h"
#include "webrtc/modules/audio_device/dummy/file_audio_device.h"
#include "webrtc/system_wrappers/include/critical_section_wrapper.h"
#include "webrtc/system_wrappers/include/trace.h"

#define CHECK_INITIALIZED()         \
{                                   \
if (!_initialized) {            \
return -1;                  \
};                              \
}

#define CHECK_INITIALIZED_BOOL()    \
{                                   \
if (!_initialized) {            \
return false;               \
};                              \
}

namespace webrtc {

    
    // ============================================================================
    //                                   Static methods
    // ============================================================================
    
    // ----------------------------------------------------------------------------
    //  AudioDeviceModule::Create()
    // ----------------------------------------------------------------------------
    AudioDeviceModule* QBAudioDeviceModuleImpl::Create(const int32_t id, const AudioLayer audioLayer)
    {
        // Create the generic ref counted (platform independent) implementation.
        RefCountImpl<QBAudioDeviceModuleImpl>* audioDevice =
        new RefCountImpl<QBAudioDeviceModuleImpl>(id, audioLayer);
        
        // Ensure that the current platform is supported.
        if (audioDevice->CheckPlatform() == -1)
        {
            delete audioDevice;
            return NULL;
        }
        
        // Create the platform-dependent implementation.
        if (audioDevice->CreatePlatformSpecificObjects() == -1)
        {
            delete audioDevice;
            return NULL;
        }
        
        // Ensure that the generic audio buffer can communicate with the
        // platform-specific parts.
        if (audioDevice->AttachAudioBuffer() == -1)
        {
            delete audioDevice;
            return NULL;
        }
        
        WebRtcSpl_Init();
        
        return audioDevice;
    }
    
    // ============================================================================
    //                            Construction & Destruction
    // ============================================================================
    
    // ----------------------------------------------------------------------------
    //  AudioDeviceModuleImpl - ctor
    // ----------------------------------------------------------------------------
    QBAudioDeviceModuleImpl::QBAudioDeviceModuleImpl(const int32_t id, const AudioLayer audioLayer) :
    _critSect(*CriticalSectionWrapper::CreateCriticalSection()),
    _critSectEventCb(*CriticalSectionWrapper::CreateCriticalSection()),
    _critSectAudioCb(*CriticalSectionWrapper::CreateCriticalSection()),
    _ptrCbAudioDeviceObserver(NULL),
    _ptrAudioDevice(NULL),
    _id(id),
    _platformAudioLayer(audioLayer),
    _lastProcessTime(TickTime::MillisecondTimestamp()),
    _platformType(kPlatformNotSupported),
    _initialized(false),
    _lastError(kAdmErrNone)
    {
        WEBRTC_TRACE(kTraceMemory, kTraceAudioDevice, id, "%s created", __FUNCTION__);
    }
    
    // ----------------------------------------------------------------------------
    //  CheckPlatform
    // ----------------------------------------------------------------------------
    int32_t QBAudioDeviceModuleImpl::CheckPlatform()
    {
        WEBRTC_TRACE(kTraceInfo, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        _platformType = kPlatformIOS;
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  CreatePlatformSpecificObjects
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::CreatePlatformSpecificObjects()
    {
        WEBRTC_TRACE(kTraceInfo, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        
        AudioDeviceGeneric* ptrAudioDevice(NULL);
        
        AudioLayer audioLayer(PlatformAudioLayer());
        
        // Create the *iPhone* implementation of the Audio Device
        //
        if (audioLayer == kPlatformDefaultAudio)
        {
            // Create iOS Audio Device implementation.
            ptrAudioDevice = new QBAudioDeviceIOS();
            WEBRTC_TRACE(kTraceInfo, kTraceAudioDevice, _id, "iPhone Audio APIs will be utilized");
        }
        
        if (ptrAudioDevice == NULL)
        {
            WEBRTC_TRACE(kTraceCritical, kTraceAudioDevice, _id, "unable to create the platform specific audio device implementation");
            return -1;
        }
        
        // Store valid output pointers
        //
        _ptrAudioDevice = ptrAudioDevice;
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  AttachAudioBuffer
    //
    //  Install "bridge" between the platform implemetation and the generic
    //  implementation. The "child" shall set the native sampling rate and the
    //  number of channels in this function call.
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::AttachAudioBuffer()
    {
        WEBRTC_TRACE(kTraceInfo, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        
        _audioDeviceBuffer.SetId(_id);
        _ptrAudioDevice->AttachAudioBuffer(&_audioDeviceBuffer);
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  ~AudioDeviceModuleImpl - dtor
    // ----------------------------------------------------------------------------
    
    QBAudioDeviceModuleImpl::~QBAudioDeviceModuleImpl()
    {
        WEBRTC_TRACE(kTraceMemory, kTraceAudioDevice, _id, "%s destroyed", __FUNCTION__);
        
        if (_ptrAudioDevice)
        {
            delete _ptrAudioDevice;
            _ptrAudioDevice = NULL;
        }
        
        delete &_critSect;
        delete &_critSectEventCb;
        delete &_critSectAudioCb;
    }
    
    // ============================================================================
    //                                  Module
    // ============================================================================
    
    // ----------------------------------------------------------------------------
    //  Module::TimeUntilNextProcess
    //
    //  Returns the number of milliseconds until the module want a worker thread
    //  to call Process().
    // ----------------------------------------------------------------------------
    
    int64_t QBAudioDeviceModuleImpl::TimeUntilNextProcess()
    {
        int64_t now = TickTime::MillisecondTimestamp();
        int64_t deltaProcess = kAdmMaxIdleTimeProcess - (now - _lastProcessTime);
        return deltaProcess;
    }
    
    // ----------------------------------------------------------------------------
    //  Module::Process
    //
    //  Check for posted error and warning reports. Generate callbacks if
    //  new reports exists.
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::Process()
    {
        
        _lastProcessTime = TickTime::MillisecondTimestamp();
        
        // kPlayoutWarning
        if (_ptrAudioDevice->PlayoutWarning())
        {
            CriticalSectionScoped lock(&_critSectEventCb);
            if (_ptrCbAudioDeviceObserver)
            {
                WEBRTC_TRACE(kTraceWarning, kTraceAudioDevice, _id, "=> OnWarningIsReported(kPlayoutWarning)");
                _ptrCbAudioDeviceObserver->OnWarningIsReported(AudioDeviceObserver::kPlayoutWarning);
            }
            _ptrAudioDevice->ClearPlayoutWarning();
        }
        
        // kPlayoutError
        if (_ptrAudioDevice->PlayoutError())
        {
            CriticalSectionScoped lock(&_critSectEventCb);
            if (_ptrCbAudioDeviceObserver)
            {
                WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "=> OnErrorIsReported(kPlayoutError)");
                _ptrCbAudioDeviceObserver->OnErrorIsReported(AudioDeviceObserver::kPlayoutError);
            }
            _ptrAudioDevice->ClearPlayoutError();
        }
        
        // kRecordingWarning
        if (_ptrAudioDevice->RecordingWarning())
        {
            CriticalSectionScoped lock(&_critSectEventCb);
            if (_ptrCbAudioDeviceObserver)
            {
                WEBRTC_TRACE(kTraceWarning, kTraceAudioDevice, _id, "=> OnWarningIsReported(kRecordingWarning)");
                _ptrCbAudioDeviceObserver->OnWarningIsReported(AudioDeviceObserver::kRecordingWarning);
            }
            _ptrAudioDevice->ClearRecordingWarning();
        }
        
        // kRecordingError
        if (_ptrAudioDevice->RecordingError())
        {
            CriticalSectionScoped lock(&_critSectEventCb);
            if (_ptrCbAudioDeviceObserver)
            {
                WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "=> OnErrorIsReported(kRecordingError)");
                _ptrCbAudioDeviceObserver->OnErrorIsReported(AudioDeviceObserver::kRecordingError);
            }
            _ptrAudioDevice->ClearRecordingError();
        }
        
        return 0;
    }
    
    // ============================================================================
    //                                    Public API
    // ============================================================================
    
    // ----------------------------------------------------------------------------
    //  ActiveAudioLayer
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::ActiveAudioLayer(AudioLayer* audioLayer) const {
        
        AudioLayer activeAudio;
        if (_ptrAudioDevice->ActiveAudioLayer(activeAudio) == -1) {
            return -1;
        }
        *audioLayer = activeAudio;
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  LastError
    // ----------------------------------------------------------------------------
    
    AudioDeviceModule::ErrorCode QBAudioDeviceModuleImpl::LastError() const
    {
        return _lastError;
    }
    
    // ----------------------------------------------------------------------------
    //  Init
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::Init()
    {
        
        if (_initialized)
            return 0;
        
        if (!_ptrAudioDevice)
            return -1;
        
        if (_ptrAudioDevice->Init() == -1)
        {
            return -1;
        }
        
        _initialized = true;
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  Terminate
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::Terminate()
    {
        
        if (!_initialized)
            return 0;
        
        if (_ptrAudioDevice->Terminate() == -1)
        {
            return -1;
        }
        
        _initialized = false;
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  Initialized
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::Initialized() const
    {
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: %d", _initialized);
        return (_initialized);
    }
    
    // ----------------------------------------------------------------------------
    //  InitSpeaker
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::InitSpeaker()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->InitSpeaker());
    }
    
    // ----------------------------------------------------------------------------
    //  InitMicrophone
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::InitMicrophone()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->InitMicrophone());
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerVolumeIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SpeakerVolumeIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->SpeakerVolumeIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetSpeakerVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetSpeakerVolume(uint32_t volume)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetSpeakerVolume(volume));
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SpeakerVolume(uint32_t* volume) const
    {
        CHECK_INITIALIZED();
        
        uint32_t level(0);
        
        if (_ptrAudioDevice->SpeakerVolume(level) == -1)
        {
            return -1;
        }
        
        *volume = level;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: volume=%u", *volume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetWaveOutVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetWaveOutVolume(uint16_t volumeLeft, uint16_t volumeRight)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetWaveOutVolume(volumeLeft, volumeRight));
    }
    
    // ----------------------------------------------------------------------------
    //  WaveOutVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::WaveOutVolume(uint16_t* volumeLeft, uint16_t* volumeRight) const
    {
        CHECK_INITIALIZED();
        
        uint16_t volLeft(0);
        uint16_t volRight(0);
        
        if (_ptrAudioDevice->WaveOutVolume(volLeft, volRight) == -1)
        {
            return -1;
        }
        
        *volumeLeft = volLeft;
        *volumeRight = volRight;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "outputs: volumeLeft=%u, volumeRight=%u",
                     *volumeLeft, *volumeRight);
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerIsInitialized
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::SpeakerIsInitialized() const
    {
        CHECK_INITIALIZED_BOOL();
        
        bool isInitialized = _ptrAudioDevice->SpeakerIsInitialized();
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: %d", isInitialized);
        return (isInitialized);
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneIsInitialized
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::MicrophoneIsInitialized() const
    {
        CHECK_INITIALIZED_BOOL();
        
        bool isInitialized = _ptrAudioDevice->MicrophoneIsInitialized();
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: %d", isInitialized);
        return (isInitialized);
    }
    
    // ----------------------------------------------------------------------------
    //  MaxSpeakerVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MaxSpeakerVolume(uint32_t* maxVolume) const
    {
        CHECK_INITIALIZED();
        
        uint32_t maxVol(0);
        
        if (_ptrAudioDevice->MaxSpeakerVolume(maxVol) == -1)
        {
            return -1;
        }
        
        *maxVolume = maxVol;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: maxVolume=%d", *maxVolume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MinSpeakerVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MinSpeakerVolume(uint32_t* minVolume) const
    {
        CHECK_INITIALIZED();
        
        uint32_t minVol(0);
        
        if (_ptrAudioDevice->MinSpeakerVolume(minVol) == -1)
        {
            return -1;
        }
        
        *minVolume = minVol;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: minVolume=%u", *minVolume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerVolumeStepSize
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SpeakerVolumeStepSize(uint16_t* stepSize) const
    {
        CHECK_INITIALIZED();
        
        uint16_t delta(0);
        
        if (_ptrAudioDevice->SpeakerVolumeStepSize(delta) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the speaker-volume step size");
            return -1;
        }
        
        *stepSize = delta;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: stepSize=%u", *stepSize);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerMuteIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SpeakerMuteIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->SpeakerMuteIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetSpeakerMute
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetSpeakerMute(bool enable)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetSpeakerMute(enable));
    }
    
    // ----------------------------------------------------------------------------
    //  SpeakerMute
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SpeakerMute(bool* enabled) const
    {
        CHECK_INITIALIZED();
        
        bool muted(false);
        
        if (_ptrAudioDevice->SpeakerMute(muted) == -1)
        {
            return -1;
        }
        
        *enabled = muted;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: enabled=%u", *enabled);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneMuteIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneMuteIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->MicrophoneMuteIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetMicrophoneMute
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetMicrophoneMute(bool enable)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetMicrophoneMute(enable));
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneMute
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneMute(bool* enabled) const
    {
        CHECK_INITIALIZED();
        
        bool muted(false);
        
        if (_ptrAudioDevice->MicrophoneMute(muted) == -1)
        {
            return -1;
        }
        
        *enabled = muted;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: enabled=%u", *enabled);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneBoostIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneBoostIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->MicrophoneBoostIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetMicrophoneBoost
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetMicrophoneBoost(bool enable)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetMicrophoneBoost(enable));
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneBoost
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneBoost(bool* enabled) const
    {
        CHECK_INITIALIZED();
        
        bool onOff(false);
        
        if (_ptrAudioDevice->MicrophoneBoost(onOff) == -1)
        {
            return -1;
        }
        
        *enabled = onOff;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: enabled=%u", *enabled);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneVolumeIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneVolumeIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->MicrophoneVolumeIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetMicrophoneVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetMicrophoneVolume(uint32_t volume)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetMicrophoneVolume(volume));
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneVolume(uint32_t* volume) const
    {
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        CHECK_INITIALIZED();
        
        uint32_t level(0);
        
        if (_ptrAudioDevice->MicrophoneVolume(level) == -1)
        {
            return -1;
        }
        
        *volume = level;
        
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "output: volume=%u", *volume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  StereoRecordingIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StereoRecordingIsAvailable(bool* available) const
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->StereoRecordingIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetStereoRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetStereoRecording(bool enable)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->RecordingIsInitialized())
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "recording in stereo is not supported");
            return -1;
        }
        
        if (_ptrAudioDevice->SetStereoRecording(enable) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to enable stereo recording");
            return -1;
        }
        
        int8_t nChannels(1);
        if (enable)
        {
            nChannels = 2;
        }
        _audioDeviceBuffer.SetRecordingChannels(nChannels);
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  StereoRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StereoRecording(bool* enabled) const
    {
        CHECK_INITIALIZED();
        
        bool stereo(false);
        
        if (_ptrAudioDevice->StereoRecording(stereo) == -1)
        {
            return -1;
        }
        
        *enabled = stereo;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: enabled=%u", *enabled);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetRecordingChannel
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetRecordingChannel(const ChannelType channel)
    {
        if (channel == kChannelBoth)
        {
        }
        else if (channel == kChannelLeft)
        {
        }
        else
        {
        }
        CHECK_INITIALIZED();
        
        bool stereo(false);
        
        if (_ptrAudioDevice->StereoRecording(stereo) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "recording in stereo is not supported");
            return -1;
        }
        
        return (_audioDeviceBuffer.SetRecordingChannel(channel));
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingChannel
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RecordingChannel(ChannelType* channel) const
    {
        CHECK_INITIALIZED();
        
        ChannelType chType;
        
        if (_audioDeviceBuffer.RecordingChannel(chType) == -1)
        {
            return -1;
        }
        
        *channel = chType;
        
        if (*channel == kChannelBoth)
        {
        }
        else if (*channel == kChannelLeft)
        {
        }
        else
        {
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  StereoPlayoutIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StereoPlayoutIsAvailable(bool* available) const
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->StereoPlayoutIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetStereoPlayout
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetStereoPlayout(bool enable)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->PlayoutIsInitialized())
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "unable to set stereo mode while playing side is initialized");
            return -1;
        }
        
        if (_ptrAudioDevice->SetStereoPlayout(enable))
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "stereo playout is not supported");
            return -1;
        }
        
        int8_t nChannels(1);
        if (enable)
        {
            nChannels = 2;
        }
        _audioDeviceBuffer.SetPlayoutChannels(nChannels);
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  StereoPlayout
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StereoPlayout(bool* enabled) const
    {
        CHECK_INITIALIZED();
        
        bool stereo(false);
        
        if (_ptrAudioDevice->StereoPlayout(stereo) == -1)
        {
            return -1;
        }
        
        *enabled = stereo;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: enabled=%u", *enabled);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetAGC
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetAGC(bool enable)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetAGC(enable));
    }
    
    // ----------------------------------------------------------------------------
    //  AGC
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::AGC() const
    {
        CHECK_INITIALIZED_BOOL();
        return (_ptrAudioDevice->AGC());
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::PlayoutIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->PlayoutIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingIsAvailable
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RecordingIsAvailable(bool* available)
    {
        CHECK_INITIALIZED();
        
        bool isAvailable(0);
        
        if (_ptrAudioDevice->RecordingIsAvailable(isAvailable) == -1)
        {
            return -1;
        }
        
        *available = isAvailable;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: available=%d", *available);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MaxMicrophoneVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MaxMicrophoneVolume(uint32_t* maxVolume) const
    {
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        CHECK_INITIALIZED();
        
        uint32_t maxVol(0);
        
        if (_ptrAudioDevice->MaxMicrophoneVolume(maxVol) == -1)
        {
            return -1;
        }
        
        *maxVolume = maxVol;
        
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "output: maxVolume=%d", *maxVolume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MinMicrophoneVolume
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MinMicrophoneVolume(uint32_t* minVolume) const
    {
        CHECK_INITIALIZED();
        
        uint32_t minVol(0);
        
        if (_ptrAudioDevice->MinMicrophoneVolume(minVol) == -1)
        {
            return -1;
        }
        
        *minVolume = minVol;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: minVolume=%u", *minVolume);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  MicrophoneVolumeStepSize
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::MicrophoneVolumeStepSize(uint16_t* stepSize) const
    {
        CHECK_INITIALIZED();
        
        uint16_t delta(0);
        
        if (_ptrAudioDevice->MicrophoneVolumeStepSize(delta) == -1)
        {
            return -1;
        }
        
        *stepSize = delta;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: stepSize=%u", *stepSize);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutDevices
    // ----------------------------------------------------------------------------
    
    int16_t QBAudioDeviceModuleImpl::PlayoutDevices()
    {
        CHECK_INITIALIZED();
        
        uint16_t nPlayoutDevices = _ptrAudioDevice->PlayoutDevices();
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: #playout devices=%d", nPlayoutDevices);
        return ((int16_t)(nPlayoutDevices));
    }
    
    // ----------------------------------------------------------------------------
    //  SetPlayoutDevice I (II)
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetPlayoutDevice(uint16_t index)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetPlayoutDevice(index));
    }
    
    // ----------------------------------------------------------------------------
    //  SetPlayoutDevice II (II)
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetPlayoutDevice(WindowsDeviceType device)
    {
        if (device == kDefaultDevice)
        {
        }
        else
        {
        }
        CHECK_INITIALIZED();
        
        return (_ptrAudioDevice->SetPlayoutDevice(device));
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutDeviceName
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::PlayoutDeviceName(
                                                       uint16_t index,
                                                       char name[kAdmMaxDeviceNameSize],
                                                       char guid[kAdmMaxGuidSize])
    {
        CHECK_INITIALIZED();
        
        if (name == NULL)
        {
            _lastError = kAdmErrArgument;
            return -1;
        }
        
        if (_ptrAudioDevice->PlayoutDeviceName(index, name, guid) == -1)
        {
            return -1;
        }
        
        if (name != NULL)
        {
            WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: name=%s", name);
        }
        if (guid != NULL)
        {
            WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: guid=%s", guid);
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingDeviceName
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RecordingDeviceName(
                                                         uint16_t index,
                                                         char name[kAdmMaxDeviceNameSize],
                                                         char guid[kAdmMaxGuidSize])
    {
        CHECK_INITIALIZED();
        
        if (name == NULL)
        {
            _lastError = kAdmErrArgument;
            return -1;
        }
        
        if (_ptrAudioDevice->RecordingDeviceName(index, name, guid) == -1)
        {
            return -1;
        }
        
        if (name != NULL)
        {
            WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: name=%s", name);
        }
        if (guid != NULL)
        {
            WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: guid=%s", guid);
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingDevices
    // ----------------------------------------------------------------------------
    
    int16_t QBAudioDeviceModuleImpl::RecordingDevices()
    {
        CHECK_INITIALIZED();
        
        uint16_t nRecordingDevices = _ptrAudioDevice->RecordingDevices();
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id,
                     "output: #recording devices=%d", nRecordingDevices);
        return ((int16_t)nRecordingDevices);
    }
    
    // ----------------------------------------------------------------------------
    //  SetRecordingDevice I (II)
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetRecordingDevice(uint16_t index)
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->SetRecordingDevice(index));
    }
    
    // ----------------------------------------------------------------------------
    //  SetRecordingDevice II (II)
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetRecordingDevice(WindowsDeviceType device)
    {
        if (device == kDefaultDevice)
        {
        }
        else
        {
        }
        CHECK_INITIALIZED();
        
        return (_ptrAudioDevice->SetRecordingDevice(device));
    }
    
    // ----------------------------------------------------------------------------
    //  InitPlayout
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::InitPlayout()
    {
        CHECK_INITIALIZED();
        _audioDeviceBuffer.InitPlayout();
        return (_ptrAudioDevice->InitPlayout());
    }
    
    // ----------------------------------------------------------------------------
    //  InitRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::InitRecording()
    {
        CHECK_INITIALIZED();
        _audioDeviceBuffer.InitRecording();
        return (_ptrAudioDevice->InitRecording());
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutIsInitialized
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::PlayoutIsInitialized() const
    {
        CHECK_INITIALIZED_BOOL();
        return (_ptrAudioDevice->PlayoutIsInitialized());
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingIsInitialized
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::RecordingIsInitialized() const
    {
        CHECK_INITIALIZED_BOOL();
        return (_ptrAudioDevice->RecordingIsInitialized());
    }
    
    // ----------------------------------------------------------------------------
    //  StartPlayout
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StartPlayout()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->StartPlayout());
    }
    
    // ----------------------------------------------------------------------------
    //  StopPlayout
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StopPlayout()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->StopPlayout());
    }
    
    // ----------------------------------------------------------------------------
    //  Playing
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::Playing() const
    {
        CHECK_INITIALIZED_BOOL();
        return (_ptrAudioDevice->Playing());
    }
    
    // ----------------------------------------------------------------------------
    //  StartRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StartRecording()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->StartRecording());
    }
    // ----------------------------------------------------------------------------
    //  StopRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StopRecording()
    {
        CHECK_INITIALIZED();
        return (_ptrAudioDevice->StopRecording());
    }
    
    // ----------------------------------------------------------------------------
    //  Recording
    // ----------------------------------------------------------------------------
    
    bool QBAudioDeviceModuleImpl::Recording() const
    {
        CHECK_INITIALIZED_BOOL();
        return (_ptrAudioDevice->Recording());
    }
    
    // ----------------------------------------------------------------------------
    //  RegisterEventObserver
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RegisterEventObserver(AudioDeviceObserver* eventCallback)
    {
        
        CriticalSectionScoped lock(&_critSectEventCb);
        _ptrCbAudioDeviceObserver = eventCallback;
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  RegisterAudioCallback
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RegisterAudioCallback(AudioTransport* audioCallback)
    {
        
        CriticalSectionScoped lock(&_critSectAudioCb);
        _audioDeviceBuffer.RegisterAudioCallback(audioCallback);
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  StartRawInputFileRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StartRawInputFileRecording(
                                                                const char pcmFileNameUTF8[kAdmMaxFileNameSize])
    {
        CHECK_INITIALIZED();
        
        if (NULL == pcmFileNameUTF8)
        {
            return -1;
        }
        
        return (_audioDeviceBuffer.StartInputFileRecording(pcmFileNameUTF8));
    }
    
    // ----------------------------------------------------------------------------
    //  StopRawInputFileRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StopRawInputFileRecording()
    {
        CHECK_INITIALIZED();
        
        return (_audioDeviceBuffer.StopInputFileRecording());
    }
    
    // ----------------------------------------------------------------------------
    //  StartRawOutputFileRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StartRawOutputFileRecording(
                                                                 const char pcmFileNameUTF8[kAdmMaxFileNameSize])
    {
        CHECK_INITIALIZED();
        
        if (NULL == pcmFileNameUTF8)
        {
            return -1;
        }
        
        return (_audioDeviceBuffer.StartOutputFileRecording(pcmFileNameUTF8));
    }
    
    // ----------------------------------------------------------------------------
    //  StopRawOutputFileRecording
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::StopRawOutputFileRecording()
    {
        CHECK_INITIALIZED();
        
        return (_audioDeviceBuffer.StopOutputFileRecording());
    }
    
    // ----------------------------------------------------------------------------
    //  SetPlayoutBuffer
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetPlayoutBuffer(const BufferType type, uint16_t sizeMS)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->PlayoutIsInitialized())
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "unable to modify the playout buffer while playing side is initialized");
            return -1;
        }
        
        int32_t ret(0);
        
        if (kFixedBufferSize == type)
        {
            if (sizeMS < kAdmMinPlayoutBufferSizeMs || sizeMS > kAdmMaxPlayoutBufferSizeMs)
            {
                WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "size parameter is out of range");
                return -1;
            }
        }
        
        if ((ret = _ptrAudioDevice->SetPlayoutBuffer(type, sizeMS)) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to set the playout buffer (error: %d)", LastError());
        }
        
        return ret;
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutBuffer
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::PlayoutBuffer(BufferType* type, uint16_t* sizeMS) const
    {
        CHECK_INITIALIZED();
        
        BufferType bufType;
        uint16_t size(0);
        
        if (_ptrAudioDevice->PlayoutBuffer(bufType, size) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the buffer type and size");
            return -1;
        }
        
        *type = bufType;
        *sizeMS = size;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: type=%u, sizeMS=%u", *type, *sizeMS);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutDelay
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::PlayoutDelay(uint16_t* delayMS) const
    {
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        CHECK_INITIALIZED();
        
        uint16_t delay(0);
        
        if (_ptrAudioDevice->PlayoutDelay(delay) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the playout delay");
            return -1;
        }
        
        *delayMS = delay;
        
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "output: delayMS=%u", *delayMS);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingDelay
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RecordingDelay(uint16_t* delayMS) const
    {
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "%s", __FUNCTION__);
        CHECK_INITIALIZED();
        
        uint16_t delay(0);
        
        if (_ptrAudioDevice->RecordingDelay(delay) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the recording delay");
            return -1;
        }
        
        *delayMS = delay;
        
        WEBRTC_TRACE(kTraceStream, kTraceAudioDevice, _id, "output: delayMS=%u", *delayMS);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  CPULoad
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::CPULoad(uint16_t* load) const
    {
        CHECK_INITIALIZED();
        
        uint16_t cpuLoad(0);
        
        if (_ptrAudioDevice->CPULoad(cpuLoad) == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the CPU load");
            return -1;
        }
        
        *load = cpuLoad;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: load=%u", *load);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetRecordingSampleRate
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetRecordingSampleRate(const uint32_t samplesPerSec)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->SetRecordingSampleRate(samplesPerSec) != 0)
        {
            return -1;
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  RecordingSampleRate
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::RecordingSampleRate(uint32_t* samplesPerSec) const
    {
        CHECK_INITIALIZED();
        
        int32_t sampleRate = _audioDeviceBuffer.RecordingSampleRate();
        
        if (sampleRate == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the sample rate");
            return -1;
        }
        
        *samplesPerSec = sampleRate;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: samplesPerSec=%u", *samplesPerSec);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetPlayoutSampleRate
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetPlayoutSampleRate(const uint32_t samplesPerSec)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->SetPlayoutSampleRate(samplesPerSec) != 0)
        {
            return -1;
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  PlayoutSampleRate
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::PlayoutSampleRate(uint32_t* samplesPerSec) const
    {
        CHECK_INITIALIZED();
        
        int32_t sampleRate = _audioDeviceBuffer.PlayoutSampleRate();
        
        if (sampleRate == -1)
        {
            WEBRTC_TRACE(kTraceError, kTraceAudioDevice, _id, "failed to retrieve the sample rate");
            return -1;
        }
        
        *samplesPerSec = sampleRate;
        
        WEBRTC_TRACE(kTraceStateInfo, kTraceAudioDevice, _id, "output: samplesPerSec=%u", *samplesPerSec);
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  ResetAudioDevice
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::ResetAudioDevice()
    {
        CHECK_INITIALIZED();
        
        
        if (_ptrAudioDevice->ResetAudioDevice() == -1)
        {
            return -1;
        }
        
        return (0);
    }
    
    // ----------------------------------------------------------------------------
    //  SetLoudspeakerStatus
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::SetLoudspeakerStatus(bool enable)
    {
        CHECK_INITIALIZED();
        
        if (_ptrAudioDevice->SetLoudspeakerStatus(enable) != 0)
        {
            return -1;
        }
        
        return 0;
    }
    
    // ----------------------------------------------------------------------------
    //  GetLoudspeakerStatus
    // ----------------------------------------------------------------------------
    
    int32_t QBAudioDeviceModuleImpl::GetLoudspeakerStatus(bool* enabled) const {
        CHECK_INITIALIZED();
        if (_ptrAudioDevice->GetLoudspeakerStatus(*enabled) != 0) {
            return -1;
        }
        return 0;
    }
    
    bool QBAudioDeviceModuleImpl::BuiltInAECIsEnabled() const {
        CHECK_INITIALIZED_BOOL();
        return _ptrAudioDevice->BuiltInAECIsEnabled();
    }
    
    bool QBAudioDeviceModuleImpl::BuiltInAECIsAvailable() const {
        CHECK_INITIALIZED_BOOL();
        return _ptrAudioDevice->BuiltInAECIsAvailable();
    }
    
    int32_t QBAudioDeviceModuleImpl::EnableBuiltInAEC(bool enable) {
        CHECK_INITIALIZED();
        return _ptrAudioDevice->EnableBuiltInAEC(enable);
    }
    
    bool QBAudioDeviceModuleImpl::BuiltInAGCIsAvailable() const {
        CHECK_INITIALIZED_BOOL();
        return _ptrAudioDevice->BuiltInAGCIsAvailable();
    }
    
    int32_t QBAudioDeviceModuleImpl::EnableBuiltInAGC(bool enable) {
        CHECK_INITIALIZED();
        return _ptrAudioDevice->EnableBuiltInAGC(enable);
    }
    
    bool QBAudioDeviceModuleImpl::BuiltInNSIsAvailable() const {
        CHECK_INITIALIZED_BOOL();
        return _ptrAudioDevice->BuiltInNSIsAvailable();
    }
    
    int32_t QBAudioDeviceModuleImpl::EnableBuiltInNS(bool enable) {
        CHECK_INITIALIZED();
        return _ptrAudioDevice->EnableBuiltInNS(enable);
    }
    
    int QBAudioDeviceModuleImpl::GetPlayoutAudioParameters(
                                                           AudioParameters* params) const {
        return _ptrAudioDevice->GetPlayoutAudioParameters(params);
    }
    
    int QBAudioDeviceModuleImpl::GetRecordAudioParameters(
                                                          AudioParameters* params) const {
        return _ptrAudioDevice->GetRecordAudioParameters(params);
    }
    
    // ============================================================================
    //                                 Private Methods
    // ============================================================================
    
    // ----------------------------------------------------------------------------
    //  Platform
    // ----------------------------------------------------------------------------
    
    QBAudioDeviceModuleImpl::PlatformType QBAudioDeviceModuleImpl::Platform() const
    {
        return _platformType;
    }
    
    // ----------------------------------------------------------------------------
    //  PlatformAudioLayer
    // ----------------------------------------------------------------------------
    
    AudioDeviceModule::AudioLayer QBAudioDeviceModuleImpl::PlatformAudioLayer() const
    {
        return _platformAudioLayer;
    }
    
}