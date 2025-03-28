/* android.cpp - module containing functions only applicable to the Android platform, usually wrapping java counterparts via JNI
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#ifdef __ANDROID__
#include <jni.h>
#include <Poco/Exception.h>
#include <SDL3/SDL.h>

static jclass TTSClass = nullptr;
static jmethodID midIsScreenReaderActive = nullptr;
static jmethodID midScreenReaderDetect = nullptr;
static jmethodID midScreenReaderSpeak = nullptr;
static jmethodID midScreenReaderSilence = nullptr;
void android_setup_jni() {
	if (TTSClass) return;
	JNIEnv* env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	if (!env) throw Poco::Exception("cannot retrieve JNI environment");
	TTSClass = env->FindClass("com/samtupy/nvgt/TTS");
	if (!TTSClass) throw Poco::Exception("cannot find TTS class");
	TTSClass = (jclass)env->NewGlobalRef(TTSClass);
	midIsScreenReaderActive = env->GetStaticMethodID(TTSClass, "isScreenReaderActive", "()Z");
	midScreenReaderDetect = env->GetStaticMethodID(TTSClass, "screenReaderDetect", "()Ljava/lang/String;");
	midScreenReaderSpeak = env->GetStaticMethodID(TTSClass, "screenReaderSpeak", "(Ljava/lang/String;Z)Z");
	midScreenReaderSilence = env->GetStaticMethodID(TTSClass, "screenReaderSilence", "()Z");
}

bool android_is_screen_reader_active() {
	android_setup_jni();
	JNIEnv* env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	return env->CallStaticBooleanMethod(TTSClass, midIsScreenReaderActive);
}

std::string android_screen_reader_detect() {
	android_setup_jni();
	JNIEnv* env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	std::string result;
	jstring jreader = (jstring)env->CallStaticObjectMethod(TTSClass, midScreenReaderDetect);
	if (!jreader) return "";
	const char* utf = env->GetStringUTFChars(jreader, 0);
	if (utf) {
		result = utf;
		env->ReleaseStringUTFChars(jreader, utf);
	}
	env->DeleteLocalRef(jreader);
	return result;
}

bool android_screen_reader_speak(const std::string& text, bool interrupt) {
	android_setup_jni();
	JNIEnv* env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	jstring jtext = env->NewStringUTF(text.c_str());
	bool result = env->CallStaticBooleanMethod(TTSClass, midScreenReaderSpeak, jtext, interrupt);
	env->DeleteLocalRef(jtext);
	return result;
}

bool android_screen_reader_silence() {
	android_setup_jni();
	JNIEnv* env = (JNIEnv*)SDL_GetAndroidJNIEnv();
	return env->CallStaticBooleanMethod(TTSClass, midScreenReaderSilence);
}

#endif // __ANDROID__
