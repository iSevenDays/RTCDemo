//
//  quickblox_audio_data_sink.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 11/01/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#ifndef quickblox_audio_data_sink_h
#define quickblox_audio_data_sink_h
// Interface for receiving audio data from a AudioTrack.

namespace webrtc {
    
    class QBAudioDataSinkInterface {
    public:
        virtual void OnData(AudioBufferList *bufferList,
                            AudioStreamBasicDescription desc,
                            UInt32 inNumberFrames,
                            bool isPlayOut ) = 0;
        
    protected:
        virtual ~QBAudioDataSinkInterface() {}
    };
};
#endif /* quickblox_audio_data_sink_h */
