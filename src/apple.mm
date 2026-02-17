/* apple.mm - code only compiled on all apple platforms
 * Thanks to Gruia Chiscop for the initial AVSpeechSynthesizer support!
 *
 * NVGT - NonVisual Gaming Toolkit
 * Copyright (c) 2022-2025 Sam Tupy
 * https://nvgt.dev
 * This software is provided "as-is", without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include <memory>
#include <vector>
#include <string>
#include <angelscript.h>
#include <scriptarray.h>
#include "apple.h"
#include "UI.h"

void register_native_tts() { tts_engine_register("avspeech", []() -> std::shared_ptr<tts_engine> { return std::make_shared<AVTTSVoice>(); }); }

// AVTTSVoice::impl class created by Gruia Chiscop on 6/6/24.
class AVTTSVoice::Impl {
public:
	float rate;
	float volume;
	float pitch;
	AVSpeechSynthesizer* synth;
	AVSpeechSynthesisVoice* currentVoice;
	NSArray<AVSpeechSynthesisVoice *> *voices;
	Impl() {
		voices = [[AVSpeechSynthesisVoice speechVoices] retain];
		currentVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
		AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] initWithString:@""];
		rate = utterance.rate;
		volume = utterance.volume;
		pitch = utterance.pitchMultiplier;
		synth = [[AVSpeechSynthesizer alloc] init];
	}
	Impl(const std::string& language) {
		voices = [[AVSpeechSynthesisVoice speechVoices] retain];
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:nslanguage];
		currentVoice = voice? voice : [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
		AVSpeechUtterance* utterance = [[AVSpeechUtterance alloc] init];
		rate = utterance.rate;
		volume = utterance.volume;
		pitch = utterance.pitchMultiplier;
		synth = [[AVSpeechSynthesizer alloc] init];
	}
	~Impl() {
		if (voices) [voices release];
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
		if (!result) return result;
		while (synth.isSpeaking) wait(5);
		return result;
	}
	bool stopSpeech() { return [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate]; }
	bool pauseSpeech() {
		if (!synth.isPaused && synth.isSpeaking) return [synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
		return false;
	}
	bool isPaused() const { return synth.isPaused; }
	bool isSpeaking() const { return synth.isSpeaking; }
	std::string getCurrentVoice() const { return [currentVoice.name UTF8String]; }
	CScriptArray* getAllVoices() const {
		asITypeInfo* arrayTipe = asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<string>");
		CScriptArray* voiceNames = CScriptArray::Create(arrayTipe, (int)0);
		for (AVSpeechSynthesisVoice *voice in voices) {
			std::string voiceName([voice.name UTF8String]);
			voiceNames->Resize(voiceNames->GetSize() + 1);
			*(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
		}
		return voiceNames;
	}
	CScriptArray* getVoicesByLanguage(const std::string& language) const {
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		asITypeInfo* arrayTipe = asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<string>");
		CScriptArray* voiceNames = CScriptArray::Create(arrayTipe, (int)0);
		for (AVSpeechSynthesisVoice *voice in voices) {
			if (![voice.language isEqualToString:nslanguage]) continue;
			std::string voiceName([voice.name UTF8String]);
			voiceNames->Resize(voiceNames->GetSize() + 1);
			*(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
		}
		return voiceNames;
	}
	void selectVoiceByName(const std::string& name) {
		NSString *nsname = [NSString stringWithUTF8String:name.c_str()];
		for (AVSpeechSynthesisVoice *voice in voices) {
			if (![voice.name isEqualToString:nsname]) continue;
			currentVoice = voice;
			break;
		}
	}
	void selectVoiceByLanguage(const std::string& language) {
		NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
		for (AVSpeechSynthesisVoice *voice in voices) {
			if (![voice.language isEqualToString:nslanguage]) continue;
			currentVoice = voice;
			break;
		}
	}
	std::string getCurrentLanguage() const { return [currentVoice.language UTF8String]; }
	NSUInteger getVoicesCount() const { return voices.count; }
	int getVoiceIndex(const std::string& name) {
		AVSpeechSynthesisVoice *voice = getVoiceObject([NSString stringWithUTF8String:name.c_str()]);
		if (!voice) return -1;
		NSUInteger result = [voices indexOfObject:voice];
		return result == NSNotFound? -1 : result;
	}
	bool setVoiceByIndex(NSUInteger index) {
		AVSpeechSynthesisVoice *oldVoice = currentVoice;
		@try {
			currentVoice = [voices objectAtIndex:index];
			return true;
		} @catch (NSException *exception) {
			currentVoice = oldVoice;
			return false;
		}
	}
	std::string getVoiceName(NSUInteger index) {
		@try { return [[voices objectAtIndex:index].name UTF8String]; }
		@catch (NSException *exception) { return ""; }
	}
	std::string getVoiceLanguage(NSUInteger index) {
		@try {
			AVSpeechSynthesisVoice *voice = [voices objectAtIndex:index];
			std::string lang([voice.language UTF8String]);
			std::transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
			return lang;
		} @catch (NSException *exception) { return ""; }
	}
private:
	AVSpeechSynthesisVoice *getVoiceObject(NSString *name) {
		for (AVSpeechSynthesisVoice *v in voices) {
			if ([v.name isEqualToString:name]) return v;
		}
		return nil;
	}
};

AVTTSVoice::AVTTSVoice() : tts_engine_impl("avspeech"), impl(new Impl()), RefCount(1) {}
AVTTSVoice::~AVTTSVoice() { delete impl; }

bool AVTTSVoice::speak(const std::string& text, bool interrupt, bool blocking) {
	if (blocking) return impl->speakWait(text, interrupt);
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
float AVTTSVoice::get_rate() { return impl->rate; }
float AVTTSVoice::get_pitch() { return impl->pitch; }
float AVTTSVoice::get_volume() { return impl->volume; }
bool AVTTSVoice::isPaused() const { return impl->isPaused(); }
bool AVTTSVoice::is_speaking() { return impl->isSpeaking(); }
void AVTTSVoice::set_rate(float rate) { impl->rate = rate; }
void AVTTSVoice::set_pitch(float pitch) { impl->pitch = pitch; }
void AVTTSVoice::set_volume(float volume) { impl->volume = volume; }
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

bool AVTTSVoice::is_available() { return impl != nullptr; }
tts_pcm_generation_state AVTTSVoice::get_pcm_generation_state() { return PCM_PREFERRED; }
bool AVTTSVoice::stop() { return impl ? impl->stopSpeech() : false; }

bool AVTTSVoice::get_rate_range(float& minimum, float& midpoint, float& maximum) { minimum = AVSpeechUtteranceMinimumSpeechRate; midpoint = AVSpeechUtteranceDefaultSpeechRate; maximum = AVSpeechUtteranceMaximumSpeechRate; return true; }
bool AVTTSVoice::get_pitch_range(float& minimum, float& midpoint, float& maximum) { minimum = 0.2; midpoint = 1; maximum = 4; return true; }
bool AVTTSVoice::get_volume_range(float& minimum, float& midpoint, float& maximum) { minimum = 0; midpoint = 0.5; maximum = 1; return true; }

int AVTTSVoice::get_voice_count() { return impl ? static_cast<int>(impl->getVoicesCount()) : 0; }

std::string AVTTSVoice::get_voice_name(int index) {
	if (!impl || index < 0 || index >= get_voice_count()) return "";
	return impl->getVoiceName(static_cast<uint64_t>(index));
}
std::string AVTTSVoice::get_voice_language(int index) {
	if (!impl || index < 0 || index >= get_voice_count()) return "";
	return impl->getVoiceLanguage(static_cast<uint64_t>(index));
}

bool AVTTSVoice::set_voice(int voice_index) {
	if (!impl || voice_index < 0 || voice_index >= get_voice_count()) return false;
	return impl->setVoiceByIndex(static_cast<uint64_t>(voice_index));
}

int AVTTSVoice::get_current_voice() {
	if (!impl) return -1;
	std::string currentVoiceName = impl->getCurrentVoice();
	return impl->getVoiceIndex(currentVoiceName);
}

tts_audio_data* AVTTSVoice::speak_to_pcm(const std::string &text) {
	if (!impl || text.empty()) return nullptr;
	if (@available(iOS 13.0, macOS 10.15, *)) {} else return nullptr;
	__block NSMutableData *audioData = [[NSMutableData alloc] init];
	__block BOOL synthesisDone = NO;
	__block AVAudioFormat *targetFormat = nil;
	__block AVAudioConverter *converter = nil;
	NSString *nstext = [NSString stringWithUTF8String:text.c_str()];
	AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:nstext];
	utterance.rate = impl->rate;
	utterance.volume = impl->volume;
	utterance.pitchMultiplier = impl->pitch;
	utterance.voice = impl->currentVoice;
	[impl->synth writeUtterance:utterance toBufferCallback:^(AVAudioBuffer * _Nonnull buffer) {
		@autoreleasepool {
			if (![buffer isKindOfClass:[AVAudioPCMBuffer class]]) return;
			AVAudioPCMBuffer *pcmBuffer = (AVAudioPCMBuffer *)buffer;
			if (pcmBuffer.frameLength == 0) { synthesisDone = YES; return; }
			if (!converter) {
				AVAudioFormat *sourceFormat = pcmBuffer.format;
				if (!sourceFormat) return;
				targetFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16 sampleRate:sourceFormat.sampleRate channels:sourceFormat.channelCount interleaved:YES];
				if (!targetFormat) return;
				converter = [[AVAudioConverter alloc] initFromFormat:sourceFormat toFormat:targetFormat];
				if (!converter) { [targetFormat release]; targetFormat = nil; return; }
			}
			AVAudioPCMBuffer *convertedBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:targetFormat frameCapacity:pcmBuffer.frameLength];
			if (!convertedBuffer) return;
			__block BOOL inputProvided = NO;
			AVAudioConverterInputBlock inputBlock = ^AVAudioBuffer *(AVAudioPacketCount inNumberOfPackets, AVAudioConverterInputStatus *outStatus) {
				if (inputProvided) { *outStatus = AVAudioConverterInputStatus_NoDataNow; return nil; }
				inputProvided = YES;
				*outStatus = AVAudioConverterInputStatus_HaveData;
				return pcmBuffer;
			};
			NSError *error = nil;
			AVAudioConverterOutputStatus status = [converter convertToBuffer:convertedBuffer error:&error withInputFromBlock:inputBlock];
			if (status == AVAudioConverterOutputStatus_HaveData && convertedBuffer.frameLength > 0) {
				NSUInteger bytesToAppend = convertedBuffer.frameLength * targetFormat.channelCount * sizeof(int16_t);
				[audioData appendBytes:convertedBuffer.int16ChannelData[0] length:bytesToAppend];
			}
		}
	}];
	NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10.0];
	while (!synthesisDone && [[NSDate date] compare:timeout] == NSOrderedAscending) [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	if (converter) [converter release];
	if (targetFormat) [targetFormat release];
	if (!synthesisDone || audioData.length == 0) return nullptr;
	unsigned int sampleRate = targetFormat ? (unsigned int)targetFormat.sampleRate : 22050;
	unsigned int channelCount = targetFormat ? (unsigned int)targetFormat.channelCount : 1;
	[audioData retain];
	return new tts_audio_data(this, (void*)audioData.bytes, (unsigned int)audioData.length, sampleRate, channelCount, 16, (void*)audioData);
}

void AVTTSVoice::free_pcm(tts_audio_data* data) {
	if (data && data->context) {
		NSMutableData* audioData = (NSMutableData*)data->context;
		[audioData release];
		data->context = nullptr;
	}
	tts_engine_impl::free_pcm(data);
}

AVTTSVoice* init() {
	return new AVTTSVoice;
}
