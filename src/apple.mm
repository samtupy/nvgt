/* apple.mm - code only compiled on all apple platforms
 * Thanks to Gruia Chiscop for the AVSpeechSynthesizer support!
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2024 Sam Tupy
 * https://nvgt.gg
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include <vector>
#include <string>
#include <angelscript.h>
#include <scriptarray.h>
#include "apple.h"
#include "UI.h"

// AVTTSVoice class created by Gruia Chiscop on 6/6/24.
class AVTTSVoice::Impl {
public:
	float rate;
	float volume;
	float pitch;
	AVSpeechSynthesizer* synth;
	AVSpeechSynthesisVoice* currentVoice;
	Impl() {
		currentVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]; //choosing english as a default language
		AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:@""];
		rate = utterance.rate;
		volume = utterance.volume;
		pitch = utterance.pitchMultiplier;
		synth = [[AVSpeechSynthesizer alloc] init];
	}
	Impl(const std::string& language) {
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:nslanguage];
		if (voice) currentVoice = voice;
		else currentVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]; //fallback to english then
		AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] init];
		rate = utterance.rate;
		volume = utterance.volume;
		pitch = utterance.pitchMultiplier;
		synth = [[AVSpeechSynthesizer alloc] init];
	}
	bool speak(const std::string& text, bool interrupt) {
		if ((interrupt || text.empty()) && synth.isSpeaking)[synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
		if (text.empty()) return interrupt;
		NSString *nstext = [NSString stringWithUTF8String:text.c_str()];
		AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:nstext];
		utterance.rate = rate;
		utterance.volume = volume;
		utterance.pitchMultiplier = pitch;
		utterance.voice = currentVoice;
		[synth speakUtterance:utterance];
		return synth.isSpeaking;
	}
	bool speakWait(const std::string& text, bool interrupt) {
		bool result = speak(text, interrupt);
		if (!result) return result; //if result is false, there's no point to continue
		while (synth.isSpeaking)
			wait(5);
		return result; //If it executes, it means that the result is true and the utterance could speak
	}
	bool stopSpeech() {
		return [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
	}
	bool pauseSpeech() {
		if (!synth.isPaused && synth.isSpeaking) return [synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
		return false;
	}
	bool isPaused() const { return synth.isPaused; }
	bool isSpeaking() const {
		return synth.isSpeaking;
	}
	std::string getCurrentVoice() const {
		NSString *nsvoiceName = currentVoice.name;
		std::string voiceName = [nsvoiceName UTF8String];
		return voiceName;
	}
	CScriptArray* getAllVoices() const {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		asITypeInfo* arrayTipe = asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<string>");
		CScriptArray* voiceNames = CScriptArray::Create(arrayTipe, (int)0);
		for (AVSpeechSynthesisVoice * voice in voices) {
			std::string voiceName = std::string([voice.name UTF8String]);
			voiceNames->Resize(voiceNames->GetSize() + 1);
			*(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
		}
		return voiceNames;
	}
	CScriptArray* getVoicesByLanguage(const std::string& language) const {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		asITypeInfo* arrayTipe = asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<string>");
		CScriptArray* voiceNames = CScriptArray::Create(arrayTipe, (int)0);
		for (AVSpeechSynthesisVoice * voice in voices) {
			if ([voice.language isEqualToString:nslanguage]) {
				std::string voiceName = std::string([voice.name UTF8String]);
				voiceNames->Resize(voiceNames->GetSize() + 1);
				*(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
			}
		}
		return voiceNames;
	}
	void selectVoiceByName(const std::string& name) {
		NSString *nsname = [NSString stringWithUTF8String:name.c_str()];
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		for (AVSpeechSynthesisVoice * voice in voices) {
			if ([voice.name isEqualToString:nsname]) {
				currentVoice = voice;
				break;
			}
		}
	}
	void selectVoiceByLanguage(const std::string& language) {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		for (AVSpeechSynthesisVoice * voice in voices) {
			if ([voice.language isEqualToString:nslanguage]) {
				currentVoice = voice;
				break;
			}
		}
	}
	std::string getCurrentLanguage() const {
		return std::string([currentVoice.language UTF8String]);
	}
	NSUInteger getVoicesCount() const {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		return voices.count;
	}
	//this method returns the index of the voice, using its name. If more than a voice has the same name, like alex from eSpeak and Alex from Apple, the first voice index will be returned.
	int getVoiceIndex(const std::string& name) {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		AVSpeechSynthesisVoice *voice = getVoiceObject([NSString stringWithUTF8String:name.c_str()]);
		if (voice) {
			NSUInteger result = [voices indexOfObject:voice];
			if (result == NSNotFound) return -1;
			return result;
		}
		return -1;
	}
	bool setVoiceByIndex(NSUInteger index) {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		AVSpeechSynthesisVoice *oldVoice = currentVoice;
		@try {
			currentVoice = [voices objectAtIndex:index];
			return true;
		} @catch (NSException *exception) {
			currentVoice = oldVoice; //I don't know if it's necessary, just for sure
			return false;
		}
	}
	std::string getVoiceName(NSUInteger index) {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		@try {
			return [[voices objectAtIndex:index].name UTF8String];
		} @catch (NSException *exception) {
			return "";
		}
	}
private:
	AVSpeechSynthesisVoice *getVoiceObject(NSString *name) {
		NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
		for (AVSpeechSynthesisVoice * v in voices) {
			if ([v.name isEqualToString:name]) return v;
		}
		return nil;
	}
};

AVTTSVoice::AVTTSVoice() : impl(new Impl()), RefCount(1) {}
AVTTSVoice::AVTTSVoice(const std::string& name) : RefCount(1), impl(new Impl(name)) {}
AVTTSVoice::~AVTTSVoice() { delete impl; }

bool AVTTSVoice::speak(const std::string& text, bool interrupt) {
	return impl->speak(text, interrupt);
}

bool AVTTSVoice::speakWait(const std::string& text, bool interrupt) {
	return impl->speakWait(text, interrupt);
}

bool AVTTSVoice::pauseSpeech() {
	return impl->pauseSpeech();
}

bool AVTTSVoice::stopSpeech() {
	return impl->stopSpeech();
}

std::string AVTTSVoice::getCurrentVoice() const {
	return impl->getCurrentVoice();
}
CScriptArray* AVTTSVoice::getAllVoices() const {
	return impl->getAllVoices();
}
CScriptArray* AVTTSVoice::getVoicesByLanguage(const std::string& language) const {
	return impl->getVoicesByLanguage(language);
}

void AVTTSVoice::setVoiceByLanguage(const std::string& language) {
	impl->selectVoiceByLanguage(language);
}
void AVTTSVoice::setVoiceByName(const std::string& name) {
	impl->selectVoiceByName(name);
}
float AVTTSVoice::getRate() const { return impl->rate; }
float AVTTSVoice::getPitch() const { return impl->pitch; }
float AVTTSVoice::getVolume() const { return impl->volume; }
bool AVTTSVoice::isPaused() const { return impl->isPaused(); }
bool AVTTSVoice::isSpeaking() const { return impl->isSpeaking(); }
void AVTTSVoice::setRate(float rate) { impl->rate = rate; }
void AVTTSVoice::setPitch(float pitch) { impl->pitch = pitch; }
void AVTTSVoice::setVolume(float volume) { impl->volume = volume; }
std::string AVTTSVoice::getCurrentLanguage() const {
	return impl->getCurrentLanguage();
}
uint64_t AVTTSVoice::getVoicesCount() const {
	return impl->getVoicesCount();
}

int AVTTSVoice::getVoiceIndex(const std::string& name) const {
	return impl->getVoiceIndex(name);
}

bool AVTTSVoice::setVoiceByIndex(uint64_t index) {
	return impl->setVoiceByIndex(index);
}
std::string AVTTSVoice::getVoiceName(uint64_t index) {
	return impl->getVoiceName(index);
}

void AVTTSVoice::init() {
	asAtomicInc(RefCount);
}

void AVTTSVoice::deinit() {
	if (asAtomicDec(RefCount) < 1) delete this;
}

AVTTSVoice* init() {
	return new AVTTSVoice;
}

AVTTSVoice* initWithName(const std::string& name) {
	return new AVTTSVoice(name);
}
