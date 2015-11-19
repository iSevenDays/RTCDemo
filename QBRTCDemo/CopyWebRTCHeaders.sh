#!/bin/sh

#  CopyWebRTCHeaders.sh
#  QBRTCDemo
#
#  Created by Anton Sokolchenko on 11/15/15.
#  Copyright © 2015 anton. All rights reserved.

source="${BASH_SOURCE[0]}"

while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
dir="$( cd -P "$( dirname "$source" )" && pwd )"
source="$(readlink "$SOURCE")"
[[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

project_dir="$( cd -P "$( dirname "$source" )" && pwd )"
echo "project dir is"
echo "$project_dir"
webrtc_source_dir="/Users/seven/Documents/work/SDK-ios-WebRTC/main/QuickbloxWebRTC/build_webrtc/webrtc"
final_headers_dir="$project_dir/webrtcheaders"
 #webrtc_source_dir= "$project_dir/webrtc"
#final_headers_dir="$webrtc_source_dir/headers"

copy_final_headers_dir() {

function create_directory_if_not_found() {

if [ ! -d "$1" ];
#        echo "$1 exist"
then
mkdir -v -p "$1"
fi
}

# 1arg - mask, 2arg - dest_dir

find_and_copy_files() {

mask=$1
dest_dir=$2
cp -R $mask $dest_dir
}

#Public headers
rm -rf $final_headers_dir
create_directory_if_not_found "$final_headers_dir"

create_directory_if_not_found "$final_headers_dir/public"

find_and_copy_files "$webrtc_source_dir/src/talk/app/webrtc/objc/public/" "$final_headers_dir/public"
#Libyuv
create_directory_if_not_found "$final_headers_dir/libyuv"
find_and_copy_files "$webrtc_source_dir/src/chromium/src/third_party/libyuv/include/" "$final_headers_dir/libyuv"

create_directory_if_not_found "$final_headers_dir/talk/media/base/"
find_and_copy_files "$webrtc_source_dir/src/talk/media/base/*.h" "$final_headers_dir/talk/media/base/"

create_directory_if_not_found "$final_headers_dir/webrtc/base/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/base/*.h" "$final_headers_dir/webrtc/base/"

##################################################COMMON VIDIO###############################################################

create_directory_if_not_found "$final_headers_dir/webrtc/common_video/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/common_video/*.h" "$final_headers_dir/webrtc/common_video/"

create_directory_if_not_found "$final_headers_dir/webrtc/common_video/interface"
find_and_copy_files "$webrtc_source_dir/src/webrtc/common_video/interface/*.h" "$final_headers_dir/webrtc/common_video/interface/"

create_directory_if_not_found "$final_headers_dir/webrtc/common_video/libyuv/include/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/common_video/libyuv/include/*.h" "$final_headers_dir/webrtc/common_video/libyuv/include/"

################################################## Modules ###############################################################
create_directory_if_not_found "$final_headers_dir/webrtc/modules/video_capture/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/modules/video_capture/*.h" "$final_headers_dir/webrtc/modules/video_capture/"

create_directory_if_not_found "$final_headers_dir/webrtc/modules/include/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/modules/include/*.h" "$final_headers_dir/webrtc/modules/include/"

create_directory_if_not_found "$final_headers_dir/webrtc/modules/video_capture/ios/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/modules/video_capture/ios/*.h" "$final_headers_dir/webrtc/modules/video_capture/ios/"

create_directory_if_not_found "$final_headers_dir/webrtc/modules/video_capture/include/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/modules/video_capture/include/*.h" "$final_headers_dir/webrtc/modules/video_capture/include/"

#################################################################################################################

create_directory_if_not_found "$final_headers_dir/webrtc/p2p/base/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/p2p/base/*.h" "$final_headers_dir/webrtc/p2p/base/"

create_directory_if_not_found "$final_headers_dir/webrtc/system_wrappers/include/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/system_wrappers/include/*.h" "$final_headers_dir/webrtc/system_wrappers/include/"

create_directory_if_not_found "$final_headers_dir/webrtc/system_wrappers/source/"
find_and_copy_files "$webrtc_source_dir/src/webrtc/system_wrappers/source/*.h" "$final_headers_dir/webrtc/system_wrappers/source/"

create_directory_if_not_found "$final_headers_dir/talk/media/base/"
find_and_copy_files "$webrtc_source_dir/src/talk/media/base/*.h" "$final_headers_dir/talk/media/base/"

create_directory_if_not_found "$final_headers_dir/talk/app/webrtc/"
find_and_copy_files "$webrtc_source_dir/src/talk/app/webrtc/*.h" "$final_headers_dir/talk/app/webrtc/"

create_directory_if_not_found "$final_headers_dir/talk/media/webrtc/"
find_and_copy_files "$webrtc_source_dir/src/talk/media/webrtc/*.h" "$final_headers_dir/talk/media/webrtc/"

create_directory_if_not_found "$final_headers_dir/talk/session/media/"
find_and_copy_files "$webrtc_source_dir/src/talk/session/media/*.h" "$final_headers_dir/talk/session/media/"

create_directory_if_not_found "$final_headers_dir/webrtc/p2p/client"
find_and_copy_files "$webrtc_source_dir/src/webrtc/p2p/client/*.h" "$final_headers_dir/webrtc/p2p/client"

create_directory_if_not_found "$final_headers_dir/talk/app/webrtc/objc"
find_and_copy_files "$webrtc_source_dir/src/talk/app/webrtc/objc/*.h" "$final_headers_dir/talk/app/webrtc/objc"

create_directory_if_not_found "$final_headers_dir/talk/media/devices/"
find_and_copy_files "$webrtc_source_dir/src/talk/media/devices/*.h" "$final_headers_dir/talk/media/devices/"

find_and_copy_files "$webrtc_source_dir/src/webrtc/*.h" "$final_headers_dir/webrtc/"
}



copy_final_headers_dir