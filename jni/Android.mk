LOCAL_PATH := $(call my-dir)
LIBPATH := ../droidev/libs/$(TARGET_ARCH_ABI)
ifneq ($(wildcard Custom.mk),)
include Custom.mk
endif
include $(CLEAR_VARS)

# static libraries
LOCAL_MODULE    := libPocoFoundation
LOCAL_SRC_FILES := $(LIBPATH)/libPocoFoundation.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoCrypto
LOCAL_SRC_FILES := $(LIBPATH)/libPocoCrypto.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoDataSQLite
LOCAL_SRC_FILES := $(LIBPATH)/libPocoDataSQLite.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoJSON
LOCAL_SRC_FILES := $(LIBPATH)/libPocoJSON.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoNet
LOCAL_SRC_FILES := $(LIBPATH)/libPocoNet.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoNetSSL
LOCAL_SRC_FILES := $(LIBPATH)/libPocoNetSSL.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoUtil
LOCAL_SRC_FILES := $(LIBPATH)/libPocoUtil.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoXML
LOCAL_SRC_FILES := $(LIBPATH)/libPocoXML.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libPocoZip
LOCAL_SRC_FILES := $(LIBPATH)/libPocoZip.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libangelscript
LOCAL_SRC_FILES := $(LIBPATH)/libangelscript.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libcrypto
LOCAL_SRC_FILES := $(LIBPATH)/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libenet6
LOCAL_SRC_FILES := $(LIBPATH)/libenet6.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libreactphysics3d
LOCAL_SRC_FILES := $(LIBPATH)/libreactphysics3d.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libssl
LOCAL_SRC_FILES := $(LIBPATH)/libssl.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libogg
LOCAL_SRC_FILES := $(LIBPATH)/libogg.a
include $(PREBUILT_STATIC_LIBRARY)

LOCAL_MODULE    := libvorbis
LOCAL_SRC_FILES := $(LIBPATH)/libvorbis.a
include $(PREBUILT_STATIC_LIBRARY)

# shared libraries
include $(CLEAR_VARS)
LOCAL_MODULE    := phonon
LOCAL_SRC_FILES := $(LIBPATH)/libphonon.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := SDL3
LOCAL_SRC_FILES := $(LIBPATH)/libSDL3.so
include $(PREBUILT_SHARED_LIBRARY)

# build settings
include $(CLEAR_VARS)
$(shell python "${LOCAL_PATH}/../build/version_sconscript.py")
LOCAL_SRC_FILES_COMMON := \
    $(subst $(LOCAL_PATH)/,, \
    $(wildcard $(LOCAL_PATH)/../ASAddon/src/*.cpp)\
    ../dep/aes.c ../dep/cmp.c ../dep/entities.cpp ../dep/ma_reverb_node.c ../dep/micropather.cpp ../dep/miniaudio.c ../dep/miniaudio_libvorbis.c ../dep/miniaudio_phonon.c ../dep/miniaudio_wdl_resampler.cpp ../dep/monocypher.c ../dep/resample.cpp ../dep/rng_get_bytes.c ../dep/singleheader.cpp ../dep/sonic.c ../dep/tinyexpr.c ../dep/uncompr.c\
    $(wildcard $(LOCAL_PATH)/../src/*.cpp))
LOCAL_C_INCLUDES_COMMON := $(LOCAL_PATH)/../droidev/include $(LOCAL_PATH)/../ASAddon/include $(LOCAL_PATH)/../dep
LOCAL_CXXFLAGS_COMMON := -DPOCO_STATIC -DNVGT_BUILDING -DAS_USE_STLNAMES=1 -std=c++20 -fms-extensions -ffunction-sections -O2 -fpermissive -O2 -Wno-narrowing -Wno-int-to-pointer-cast -Wno-delete-incomplete -Wno-unused-result -Wno-deprecated-array-compare -Wno-implicit-const-int-float-conversion -Wno-deprecated-enum-enum-conversion -Wno-absolute-value
LOCAL_LDFLAGS_COMMON = -Wl,--no-fatal-warnings -Wl,--no-undefined -Wl,--gc-sections
LOCAL_SHARED_LIBRARIES_COMMON := SDL3 phonon
LOCAL_STATIC_LIBRARIES_COMMON := libPocoFoundation libPocoCrypto libPocoDataSQLite libPocoJSON libPocoNet libPocoNetSSL libPocoUtil libPocoXML libPocoZip libangelscript libcrypto libenet6 libreactphysics3d libssl libogg libvorbis
LOCAL_LDLIBS_COMMON := -lGLESv1_CM -lGLESv2 -lOpenSLES -llog -landroid
LOCAL_CPP_FEATURES_COMMON := rtti exceptions

# A default invocation to ndk-build will cause both runner and stubs to build, call ndk-build BUILD_STUB=0 to disable the stub, for example. Used mostly by gradle.
BUILD_RUNNER := 1
BUILD_STUB := 1

ifeq ($(BUILD_RUNNER), 1)
# NVGT runner
include $(CLEAR_VARS)
LOCAL_MODULE := main
LOCAL_SRC_FILES := $(LOCAL_SRC_FILES_COMMON)
LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES_COMMON)
LOCAL_CXXFLAGS := $(LOCAL_CXXFLAGS_COMMON)
LOCAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES_COMMON)
LOCAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES_COMMON)
LOCAL_LDLIBS := $(LOCAL_LDLIBS_COMMON)
LOCAL_CPP_FEATURES := $(LOCAL_CPP_FEATURES_COMMON)
LOCAL_DISABLE_FATAL_LINKER_WARNINGS := true
LOCAL_LDFLAGS := $(LOCAL_LDFLAGS_COMMON)
ifneq ($(wildcard Custom.mk),)
include Custom.mk
endif
include $(BUILD_SHARED_LIBRARY)
endif

ifeq ($(BUILD_STUB), 1)
# NVGT stub
include $(CLEAR_VARS)
LOCAL_MODULE := game
LOCAL_SRC_FILES := $(LOCAL_SRC_FILES_COMMON)
LOCAL_C_INCLUDES := $(LOCAL_C_INCLUDES_COMMON)
LOCAL_CXXFLAGS := $(LOCAL_CXXFLAGS_COMMON) -DNVGT_STUB
LOCAL_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES_COMMON)
LOCAL_STATIC_LIBRARIES := $(LOCAL_STATIC_LIBRARIES_COMMON)
LOCAL_LDLIBS := $(LOCAL_LDLIBS_COMMON)
LOCAL_CPP_FEATURES := $(LOCAL_CPP_FEATURES_COMMON)
LOCAL_DISABLE_FATAL_LINKER_WARNINGS := true
LOCAL_LDFLAGS := $(LOCAL_LDFLAGS_COMMON)
ifneq ($(wildcard Custom.mk),)
include Custom.mk
endif
include $(BUILD_SHARED_LIBRARY)
endif
