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
        'target_name': 'webrtc_objc_target',
        'type': 'static_library',
        'dependencies': [
            '../talk/app/webrtc/legacy_objc_api.gyp:libjingle_peerconnection_objc',
			'<(webrtc_root)/base/base.gyp:rtc_base_objc',
			'<(webrtc_root)/api/api.gyp:rtc_api_objc',
            '<(webrtc_root)/system_wrappers/system_wrappers.gyp:field_trial_default'
        ],
    
        'sources': [
        ],
		
		'export_dependent_settings': [
		'../talk/app/webrtc/legacy_objc_api.gyp:libjingle_peerconnection_objc',
		'<(webrtc_root)/base/base.gyp:rtc_base_objc',
		'<(webrtc_root)/api/api.gyp:rtc_api_objc',
		],
		

        'all_dependent_settings': {
            'xcode_settings': {
                'CLANG_ENABLE_OBJC_ARC': 'YES',
            },
        },
        
        'xcode_settings': {
            'CLANG_ENABLE_OBJC_ARC': 'YES',
            # common.gypi enables this for mac but we want this to be disabled
            # like it is for ios.
            'CLANG_WARN_OBJC_MISSING_PROPERTY_SYNTHESIS': 'NO',
        },
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
#def findSubstringInLines(lines, find):
#	for i, line in enumerate(lines):
#	if find in line:
#		return i
#			return -1
#
#def isStringAlreadyAppended(f, s):
#	with open(f) as content:
#	data = content.read()
#	return s in data
#
#if isStringAlreadyAppended(FILE, APPEND):
#	exit(0)
#
#with open(FILE, 'r+') as content:
#	lines = content.readlines()
#		index = findSubstringInLines(lines, FIND)
#
#if index < 0:
#	exit(-1)
#
#lines.insert(index + 2, APPEND)
#
#with open(FILE, 'r+') as content:
#	content.write("".join(lines))
#		content.truncate()
