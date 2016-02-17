#!/bin/sh

#  build.sh
#  WebRTC

source="${BASH_SOURCE[0]}"

while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
    dir="$( cd -P "$( dirname "$source" )" && pwd )"
    source="$(readlink "$SOURCE")"
    [[ $source != /* ]] && source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
#text
line="%47s▫️▫️▫️\n"
arr="➩"
#URLS
user_webrtc_url=""
default_webrtc_url="https://chromium.googlesource.com/external/webrtc"
depot_tools_url="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
#Directories
project_dir="$( cd -P "$( dirname "$source" )" && pwd )"
webrtc_source_dir="$project_dir/webrtc"
depot_tools_dir="$project_dir/depot_tools"

final_libs_dir="$webrtc_source_dir/lib"
final_headers_dir="$webrtc_source_dir/headers"

prefix_out="out_"

webrtc_target="webrtc_objc_target"
printf "Environment variables:\n"
printf "    webrtc_debug    $arr $webrtc_debug\n"
printf "    webrtc_profile  $arr $webrtc_profile\n"
printf "    webrtc_release  $arr $webrtc_release\n"

printf $line

printf "URLs:\n"
printf "    User webrtc     $arr $user_webrtc_url\n"
printf "    Default webrtc  $arr $default_webrtc_url\n"
printf "    Depot tools     $arr $depot_tools_url\n"

printf $line

printf "Directories:\n"
printf "    Project         $arr $project_dir\n"
printf "    Depot tools     $arr $depot_tools_dir\n"
printf "    Final libs      $arr $final_libs_dir\n"

printf $line

printf "Build target:\n"
printf "    $arr $webrtc_target\n"

function create_directory_if_not_found() {

    if [ ! -d "$1" ];
        echo "$1 exist"
    then
        mkdir -v -p "$1"
    fi
}

function exec_libtool() {

  echo "Running libtool"
  libtool -static -v -o $@
}

function exec_strip() {

  echo "Running strip"
  strip -S -x -v $@
}

function exec_ninja() {

  echo "Running ninja"
  echo ninja -C $1
  ninja -C $1
}

# Update/Get/Ensure the Gclient Depot Tools
function pull_depot_tools() {

    WORKING_DIR=`pwd`

    printf "%40s Pull depot tools:\n\n"

    echo "Get the current working directory so we can change directories back when done"
    echo "If no directory where depot tools should be..."

    if [ ! -d $depot_tools_dir ]
    then
        echo "Make directory for gclient called Depot Tools"
        mkdir -p $depot_tools_dir

        echo "Pull the depot tools project from chromium source into the depot tools directory"
        git clone $depot_tools_url $depot_tools_dir

    else

        echo "Change directory into the depot tools"
        cd $depot_tools_dir

        echo "Pull the depot tools down to the latest"
        git pull
    fi

    PATH="$PATH:$depot_tools_dir"

    echo "Go back to working directory"
    cd $WORKING_DIR
}

# Set the base of the GYP defines, instructing gclient runhooks what to generate
function wrbase() {

    export GYP_DEFINES="chromium_ios_signing=0 clang_xcode=1 use_objc_h264=1 include_tests=0 build_with_libjingle=1 libjingle_objc=1 python_ver=2.7 build_with_chromium=0"
    export GYP_GENERATORS="ninja"
    export GYP_GENERATOR_FLAGS="output_dir=$out_$1"
}

# Add the iOS Device specific defines on top of the base
function arm() {

    wrbase $1
    export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=arm"
	export GYP_GENERATORS="$GYP_GENERATORS,xcode,xcode-ninja"
    export GYP_CROSSCOMPILE=1
}

# Add the iOS ARM 64 Device specific defines on top of the base
function arm64() {

    wrbase $1
    export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=arm64"
    export GYP_CROSSCOMPILE=1
}

# Add the iOS Simulator X86 specific defines on top of the base

function ia32() {

    wrbase $1
    export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=ia32"
}

# Add the iOS Simulator X64 specific defines on top of the base
function x86_64() {

    wrbase $1
    export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=x64 target_subarch=arm64 msan=1"
}

## Gets the revision number of the current WebRTC svn repo on the filesystem
function get_revision_number() {

    DIR=`pwd`
    cd "$webrtc_source_dir/src"

    REVISION_NUMBER=`git log -1 | grep 'Cr-Commit-Position: refs/heads/master@{#' | egrep -o "[0-9]+}" | tr -d '}'`

    if [ -z "$REVISION_NUMBER" ]
    then
        REVISION_NUMBER=`git log -1 | grep 'Cr-Commit-Position: refs/branch-heads/' | egrep -o "[0-9]+" | awk 'NR%2{printf $0"-";next;}1'`
    fi

    if [ -z "$REVISION_NUMBER" ]
    then
        REVISION_NUMBER=`git describe --tags | sed 's/\([0-9]*\)-.*/\1/'`
    fi

    if [ -z "$REVISION_NUMBER" ]
    then
        echo "Error grabbing revision number"
        exit 1
    fi

    echo $REVISION_NUMBER
    cd $DIR
}

# This function allows you to pull the latest changes from WebRTC without doing an entire clone, much faster to build and try changes
# Pass in a revision number as an argument to pull that specific revision ex: update2Revision 6798

function update2Revision() {
    # Ensure that we have gclient added to our environment, so this function can run standalone
    cd $webrtc_source_dir
    printf "%40s🔸Update to revision: $1\n\n"
    # Setup gclient config
    echo "Configuring gclient for iOS build:"

    if [ -n "$user_webrtc_url"]
    then
        echo "User has not specified a different webrtc url. Using default"
        gclient config --unmanaged --name=src "$default_webrtc_url"
    else
        echo "User has specified their own webrtc url $user_webrtc_url"
        gclient config --unmanaged --name=src "$user_webrtc_url"
    fi

    echo "target_os = ['ios', 'mac']" >> .gclient

    if [ -z $1 ]
    then
        sync_webrtc
    else
        sync_webrtc "$1"
    fi

    # Inject the new target
    inject_blox_target

    echo "webrtc has been successfully updated"
}

# Fire the sync command. Accepts an argument as the revision number that you want to sync to
function sync_webrtc() {

    echo "\nGlient sync $1"

    cd $webrtc_source_dir

    reject_blox_target

    if [ -z $1 ]
    then
        gclient sync --with_branch_heads || true
    else
        gclient sync -r "$1" --with_branch_heads || true
    fi
}

function inject_blox_target () {

    cd $webrtc_source_dir
    echo "\nInject a new $webrtc_target target $project_dir/blox_target.py"

    python "$project_dir/blox_target.py" "$webrtc_source_dir/src/webrtc/webrtc_examples.gyp"
}

function reject_blox_target () {

    if [ -d $webrtc_source_dir/src ]; then

        cd $webrtc_source_dir/src
        file_changed=`git status --porcelain webrtc/webrtc_examples.gyp | awk '/^ M/{ print $2 }'`

        if [ "$file_changed" == "webrtc/webrtc_examples.gyp" ] ; then

            echo "🔴Reject the $webrtc_target target"
            git checkout -- webrtc/webrtc_examples.gyp
        fi
    fi
}

# 1arg - mask, 2arg - dest_dir

function find_and_copy_files() {

    mask=$1
    dest_dir=$2
    cp -R $mask $dest_dir
}

function copyHeaders() {

    echo "copyHeaders"
    create_directory_if_not_found "$final_headers_dir/$1"
    find_and_copy_files "$webrtc_source_dir/src/$1*.h" "$final_headers_dir/$1"
}

copy_final_headers_dir() {

    rm -rf $final_headers_dir
    create_directory_if_not_found "$final_headers_dir"

    dirList=(
        'chromium/src/third_party/libyuv/include/'
        'chromium/src/third_party/libyuv/include/libyuv/'
        'webrtc/'
        'webrtc/media/base/'
#		'webrtc/api/'
#		'webrtc/api/objc/'
        'webrtc/audio/'
        'webrtc/base/'
		'webrtc/base/objc/'
        'webrtc/common_video/'
        'webrtc/common_video/include/'
        'webrtc/common_video/libyuv/include/'
        'webrtc/common_audio/signal_processing/include/'
        'webrtc/modules/video_capture/'
        'webrtc/modules/include/'
        'webrtc/modules/video_capture/ios/'
        'webrtc/modules/audio_device/'
        'webrtc/modules/audio_device/dummy/'
        'webrtc/modules/audio_device/include/'
        'webrtc/modules/utility/include/'
        'webrtc/p2p/base/'
        'webrtc/system_wrappers/include/'
        'webrtc/system_wrappers/source/'
        'talk/app/webrtc/'
		'talk/app/webrtc/objc/'
		'talk/app/webrtc/objc/public/'
        'talk/session/media/'
        'webrtc/p2p/client/'
        'webrtc/media/devices/'
		'webrtc/webrtc/'
    )

    for dir in ${dirList[@]}; do
        copyHeaders $dir
    done
}

function build_t() {

    printf "%40s Build: $1\n"

    cd "$webrtc_source_dir/src"

    arch="$1"
    out_dir="$prefix_out$arch"

    $1 $out_dir

    gclient runhooks

    WEBRTC_REVISION=`get_revision_number`

    if [ $webrtc_debug = true ] ; then

        exec_ninja "$out_dir/Debug$2/"
        exec_libtool "$final_libs_dir/webrtc-$arch.a" "$webrtc_source_dir/src/$out_dir/Debug$2/*.a"
    fi

    if [ $webrtc_profile = true ] ; then

        exec_ninja "$out_dir/Profile$2/"
        exec_libtool "$final_libs_dir/webrtc-$arch.a" "$webrtc_source_dir/src/$out_dir/Profile$2/*.a"
    fi

    if [ $webrtc_release = true ] ; then

        exec_ninja "$out_dir/Release$2/"
        exec_libtool "$final_libs_dir/webrtc-$arch.a" "$webrtc_source_dir/src/$out_dir/Release$2/*.a"
        exec_strip "$final_libs_dir/webrtc-$arch.a"
    fi
}

# This function is used to put together the intel (simulator), armv7 and arm64 builds (device) into one static library so its easy to deal with in Xcode
# Outputs the file into the build directory with the revision number
function lipo_intel_and_arm() {

    if [ "webrtc_source_dir_DEBUG" = true ] ; then
        lipo_for_configuration "Debug"
    fi

    if [ "webrtc_source_dir_PROFILE" = true ] ; then
        lipo_for_configuration "Profile"
    fi

    if [ "webrtc_source_dir_RELEASE" = true ] ; then
        lipo_for_configuration "Release"
    fi
}

# Get webrtc then build webrtc
function dance() {

#    # These next if statement trickery is so that if you run from the command line and don't set anything to build, it will default to the debug profile.@
#
#	# check for webrtc revision
#	# if equal, skip dance and exit
#    if [ -f $webrtc_source_dir/revision.txt ]; then
#		echo "revision.txt exists."
#		line=$(head -n 1 $webrtc_source_dir/revision.txt)
#
#		if [ "$line" == "$webrtc_revision" ]; then
#			echo "Revision has not changed"
#
#			# need to check if libs dir is empty
#			# every folder cotains .ds_store, so we need to check count of files in dir
#			count=$(find $final_libs_dir -maxdepth 1 -name '*.a' | wc -l)
#			# must be 4 .a files
#			if [ $count == 4 ]; then
#				# not empty
#				echo "And all libs in $final_libs_dir are present, stopping... $count"
#				exit 0
#			else
#				echo "But $final_libs_dir folder does not contain all libraries, so trying to continue build"
#			fi
#		else
#			echo "Revision has changed since last build"
#		fi
#	fi
#
#	rm -rf $final_libs_dir
#	echo "Previous webrtc libraries .a has been removed in the folder $final_libs_dir"
#
#	echo "$webrtc_revision" > $webrtc_source_dir/revision.txt


    BUILD_DEBUG=true

    if [ "$webrtc_release" = true ] ; then
        BUILD_DEBUG=false
    fi

    if [ "$webrtc_profile" = true ] ; then
        BUILD_DEBUG=false
    fi

    if [ "$webrtc_debug" = true ] ; then
        BUILD_DEBUG=true
    fi

    create_directory_if_not_found "$webrtc_source_dir"
    create_directory_if_not_found "$final_libs_dir"

    pull_depot_tools

    # Pass in an argument if you want to get a specific webrtc revision
    update2Revision $webrtc_revision

    build_t "ia32" "-iphonesimulator"
    build_t "x86_64" "-iphonesimulator"
    build_t "arm64" "-iphoneos"
    build_t "arm" "-iphoneos"

    copy_final_headers_dir
}

dance
echo "Build is Finished"
