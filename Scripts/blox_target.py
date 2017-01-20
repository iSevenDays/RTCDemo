#!/usr/bin/python

# add this to Append
#'link_settings': {
#	'libraries': [
				  #				  '-lstdc++',
				  #				  ],
#	},
#		dependencies	'<(webrtc_root)/base/base.gyp:rtc_base_objc''
#'<(webrtc_root)/api/api.gyp:rtc_api_objc',

import sys, ast, json

FILE = sys.argv[1]

FIND = """    ['OS=="ios" or (OS=="mac" and target_arch!="ia32")', {"""
APPEND = """
	{
   'target_name':'webrtc_shared',
   'type':'shared_library',
   'xcode_settings':{
   'IPHONEOS_DEPLOYMENT_TARGET': '7.0',
   },
   'dependencies':[
      '<(webrtc_root)/api/api.gyp:libjingle_peerconnection',
      '<(webrtc_root)/system_wrappers/system_wrappers.gyp:field_trial_default'
   ],

},
{
   'target_name':'webrtc_objc_target',
   'type':'static_library',
   'dependencies':[
      'webrtc_shared',
      '<(webrtc_root)/api/api.gyp:libjingle_peerconnection',
      '<(webrtc_root)/system_wrappers/system_wrappers.gyp:field_trial_default'
   ],
   'sources':[
      '../talk/app/webrtc/objc/RTCAudioTrack+Internal.h',
      '../talk/app/webrtc/objc/RTCAudioTrack.mm',
      '../talk/app/webrtc/objc/RTCDataChannel+Internal.h',
      '../talk/app/webrtc/objc/RTCDataChannel.mm',
      '../talk/app/webrtc/objc/RTCEnumConverter.h',
      '../talk/app/webrtc/objc/RTCEnumConverter.mm',
      '../talk/app/webrtc/objc/RTCI420Frame+Internal.h',
      '../talk/app/webrtc/objc/RTCI420Frame.mm',
      '../talk/app/webrtc/objc/RTCIceCandidate+Internal.h',
      '../talk/app/webrtc/objc/RTCIceCandidate.mm',
      '../talk/app/webrtc/objc/RTCIceServer+Internal.h',
      '../talk/app/webrtc/objc/RTCIceServer.mm',
      '../talk/app/webrtc/objc/RTCMediaConstraints+Internal.h',
      '../talk/app/webrtc/objc/RTCMediaConstraints.mm',
      '../talk/app/webrtc/objc/RTCMediaConstraintsNative.cc',
      '../talk/app/webrtc/objc/RTCMediaConstraintsNative.h',
      '../talk/app/webrtc/objc/RTCMediaSource+Internal.h',
      '../talk/app/webrtc/objc/RTCMediaSource.mm',
      '../talk/app/webrtc/objc/RTCMediaStream+Internal.h',
      '../talk/app/webrtc/objc/RTCMediaStream.mm',
      '../talk/app/webrtc/objc/RTCMediaStreamTrack+Internal.h',
      '../talk/app/webrtc/objc/RTCMediaStreamTrack.mm',
      '../talk/app/webrtc/objc/RTCOpenGLVideoRenderer.mm',
      '../talk/app/webrtc/objc/RTCPair.m',
      '../talk/app/webrtc/objc/RTCPeerConnection+Internal.h',
      '../talk/app/webrtc/objc/RTCPeerConnection.mm',
      '../talk/app/webrtc/objc/RTCPeerConnectionFactory.mm',
      '../talk/app/webrtc/objc/RTCPeerConnectionInterface+Internal.h',
      '../talk/app/webrtc/objc/RTCPeerConnectionInterface.mm',
      '../talk/app/webrtc/objc/RTCPeerConnectionObserver.h',
      '../talk/app/webrtc/objc/RTCPeerConnectionObserver.mm',
      '../talk/app/webrtc/objc/RTCSessionDescription+Internal.h',
      '../talk/app/webrtc/objc/RTCSessionDescription.mm',
      '../talk/app/webrtc/objc/RTCStatsReport+Internal.h',
      '../talk/app/webrtc/objc/RTCStatsReport.mm',
      '../talk/app/webrtc/objc/RTCVideoCapturer+Internal.h',
      '../talk/app/webrtc/objc/RTCVideoCapturer.mm',
      '../talk/app/webrtc/objc/RTCVideoRendererAdapter.h',
      '../talk/app/webrtc/objc/RTCVideoRendererAdapter.mm',
      '../talk/app/webrtc/objc/RTCVideoSource+Internal.h',
      '../talk/app/webrtc/objc/RTCVideoSource.mm',
      '../talk/app/webrtc/objc/RTCVideoTrack+Internal.h',
      '../talk/app/webrtc/objc/RTCVideoTrack.mm',
      '../talk/app/webrtc/objc/public/RTCAudioSource.h',
      '../talk/app/webrtc/objc/public/RTCAudioTrack.h',
      '../talk/app/webrtc/objc/public/RTCDataChannel.h',
      '../talk/app/webrtc/objc/public/RTCFileLogger.h',
      '../talk/app/webrtc/objc/public/RTCI420Frame.h',
      '../talk/app/webrtc/objc/public/RTCIceCandidate.h',
      '../talk/app/webrtc/objc/public/RTCIceServer.h',
      '../talk/app/webrtc/objc/public/RTCLogging.h',
      '../talk/app/webrtc/objc/public/RTCMediaConstraints.h',
      '../talk/app/webrtc/objc/public/RTCMediaSource.h',
      '../talk/app/webrtc/objc/public/RTCMediaStream.h',
      '../talk/app/webrtc/objc/public/RTCMediaStreamTrack.h',
      '../talk/app/webrtc/objc/public/RTCOpenGLVideoRenderer.h',
      '../talk/app/webrtc/objc/public/RTCPair.h',
      '../talk/app/webrtc/objc/public/RTCPeerConnection.h',
      '../talk/app/webrtc/objc/public/RTCPeerConnectionDelegate.h',
      '../talk/app/webrtc/objc/public/RTCPeerConnectionFactory.h',
      '../talk/app/webrtc/objc/public/RTCPeerConnectionInterface.h',
      '../talk/app/webrtc/objc/public/RTCSessionDescription.h',
      '../talk/app/webrtc/objc/public/RTCSessionDescriptionDelegate.h',
      '../talk/app/webrtc/objc/public/RTCStatsDelegate.h',
      '../talk/app/webrtc/objc/public/RTCStatsReport.h',
      '../talk/app/webrtc/objc/public/RTCTypes.h',
      '../talk/app/webrtc/objc/public/RTCVideoCapturer.h',
      '../talk/app/webrtc/objc/public/RTCVideoRenderer.h',
      '../talk/app/webrtc/objc/public/RTCVideoSource.h',
      '../talk/app/webrtc/objc/public/RTCVideoTrack.h',

   ],
   'export_dependent_settings':[
      '<(webrtc_root)/api/api.gyp:libjingle_peerconnection',

   ],
   'direct_dependent_settings':{
      'include_dirs':[
         '<(DEPTH)/talk/app/webrtc/objc/public',
      ],

   },
   'include_dirs':[
      '<(webrtc_root)/webrtc/api',
      '<(DEPTH)/talk/app/webrtc/objc',
      '<(DEPTH)/talk/app/webrtc/objc/public',
   ],
   'all_dependent_settings':{
      'xcode_settings':{
		 'IPHONEOS_DEPLOYMENT_TARGET': '7.0',
         'CLANG_ENABLE_OBJC_ARC':'YES',
      },

   },
   'xcode_settings':{
      'CLANG_ENABLE_OBJC_ARC':'YES',
	  'IPHONEOS_DEPLOYMENT_TARGET': '7.0',
      # common.gypi enables this for mac but we want this to be disabled
            # like it is for ios.
            'CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS':'NO',
      'WARNING_CFLAGS':[
         '-Wno-unused-property-ivar',
      ],

   },
   'conditions':[
      [
         'OS=="ios"',
         {
            'sources':[
               '../talk/app/webrtc//objc/avfoundationvideocapturer.h',
               '../talk/app/webrtc/objc/avfoundationvideocapturer.mm',
               '../talk/app/webrtc/objc/RTCAVFoundationVideoSource+Internal.h',
               '../talk/app/webrtc/objc/RTCAVFoundationVideoSource.mm',
               '../talk/app/webrtc/objc/RTCEAGLVideoView.m',
               '../talk/app/webrtc/objc/public/RTCEAGLVideoView.h',
               '../talk/app/webrtc/objc/public/RTCAVFoundationVideoSource.h',

            ],
            'dependencies':[
            ],
            'link_settings':{
               'xcode_settings':{
                  'OTHER_LDFLAGS':[
                     '-framework CoreGraphics',
                     '-framework GLKit',

                  ],
               },
            },
         }
      ],
   ],
},

"""

def findSubstringInLines(lines, find):
    for i, line in enumerate(lines):
        if find in line:
            return i
    return -1

def isStringAlreadyAppended(f, s):
    with open(f) as content:
        data = content.read()
        return s in data

if isStringAlreadyAppended(FILE, APPEND):
    exit(0)

with open(FILE, 'r+') as content:
    lines = content.readlines()
    index = findSubstringInLines(lines, FIND)

if index < 0:
    exit(-1)

lines.insert(index + 2, APPEND)

with open(FILE, 'r+') as content:
    content.write("".join(lines))
    content.truncate()


# add this to Append
#'link_settings': {
#	'libraries': [
#				  '-lstdc++',
#				  ],
#	},
#		dependencies	'<(webrtc_root)/base/base.gyp:rtc_base_objc''
#'<(webrtc_root)/api/api.gyp:rtc_api_objc',
#
#import sys, ast, json
#
#FILE = sys.argv[1]
#
#FIND = """    ['OS=="ios" or (OS=="mac" and target_arch!="ia32")', {"""
#APPEND = """
#	{
#	'target_name': 'webrtc_objc_target',
#	'type': 'static_library',
#	'dependencies': [
#	'../talk/app/webrtc/legacy_objc_api.gyp:libjingle_peerconnection_objc',
#	'<(webrtc_root)/system_wrappers/system_wrappers.gyp:field_trial_default',
#	],
#	
#	'sources': [
#	],
#	
#	'export_dependent_settings': [
#	'../talk/app/webrtc/legacy_objc_api.gyp:libjingle_peerconnection_objc',
#	],
#	
#	
#	'all_dependent_settings': {
#	'xcode_settings': {
#	'CLANG_ENABLE_OBJC_ARC': 'YES',
#	},
#	},
#	
#	'xcode_settings': {
#	'CLANG_ENABLE_OBJC_ARC': 'YES',
#	# common.gypi enables this for mac but we want this to be disabled
#	# like it is for ios.
#	'CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS': 'NO',
#	
#	},
#	},
#	"""
#
