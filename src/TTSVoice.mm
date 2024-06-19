
/*TTSVoice.mm, the implementation file for TTSVoice class
 *This class brings in NVGT the AVSpeech support for macOS
 */
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include "TTSVoice.h"
#include "ui.h"
#include <vector>
#include <string>
class TTSVoice::Impl {
public:
    float rate;
    float volume;
    float pitch;
    AVSpeechSynthesizer* synth;
    AVSpeechSynthesisVoice* currentVoice;
    AVSpeechUtterance* utterance;
    Impl() {
currentVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]; //choosing english as a default language
        utterance = [[AVSpeechUtterance alloc] initWithString:@""];
        rate = utterance.rate;
        volume = utterance.volume;
        pitch = utterance.pitchMultiplier;
        synth = [[AVSpeechSynthesizer alloc] init];
    }
    Impl(const std::string& language) {
        NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:nslanguage];
        if(voice) currentVoice=voice;
        else currentVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]; //fallback to english then
utterance = [[AVSpeechUtterance alloc] init];
        rate = utterance.rate;
        volume = utterance.volume;
        pitch = utterance.pitchMultiplier;
        synth = [[AVSpeechSynthesizer alloc] init];
    }
    bool speak(const std::string& text, bool interrupt) {
        if(interrupt && synth.isSpeaking) [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        NSString *nstext = [NSString stringWithUTF8String:text.c_str()];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:nstext];
        utterance.rate = rate;
        utterance.volume = volume;
        utterance.pitchMultiplier = pitch;
        utterance.voice = currentVoice;
        this->utterance = utterance;
        [synth speakUtterance:this->utterance];
        return synth.isSpeaking;
    }
    bool speakWait(const std::string& text, bool interrupt) {
        bool result = speak(text, interrupt);
        if(!result) return result; //if result is false, there's no point to continue
        while(synth.isSpeaking) {
            wait(5);
        }
        return result; //If it executes, it means that the result is true and the utterance could speak
    }
    bool stopSpeech() {
        if(synth.isSpeaking) return [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        return false;
    }
    bool pauseSpeech() {
        if(!synth.isPaused && synth.isSpeaking) return [synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
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
        for(AVSpeechSynthesisVoice *voice in voices) {
            std::string voiceName = std::string([voice.name UTF8String]);
            voiceNames->Resize(voiceNames->GetSize()+1);
            *(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
        }
        return voiceNames;
    }
    CScriptArray* getVoicesByLanguage(const std::string& language) const {
        NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
        NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
        asITypeInfo* arrayTipe = asGetActiveContext()->GetEngine()->GetTypeInfoByDecl("array<string>");
        CScriptArray* voiceNames = CScriptArray::Create(arrayTipe, (int)0);
        for(AVSpeechSynthesisVoice *voice in voices) {
            if([voice.language isEqualToString:nslanguage]) {
                std::string voiceName = std::string([voice.name UTF8String]);
            voiceNames->Resize(voiceNames->GetSize()+1);
            *(std::string*)voiceNames->At(voiceNames->GetSize() - 1) = voiceName;
            }
        }
        return voiceNames;
    }
    void selectVoiceByName(const std::string& name) {
        NSString *nsname = [NSString stringWithUTF8String:name.c_str()];
        NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
        for(AVSpeechSynthesisVoice *voice in voices) {
            if([voice.name isEqualToString:nsname]) {
                currentVoice = voice;
                break;
            }
        }
    }
    void selectVoiceByLanguage(const std::string& language) {
        NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
        NSString *nslanguage = [NSString stringWithUTF8String:language.c_str()];
        for(AVSpeechSynthesisVoice *voice in voices) {
            if([voice.language isEqualToString:nslanguage]) {
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
        if(voice) {
            NSUInteger result = [voices indexOfObject:voice];
            if(result == NSNotFound) return -1;
            return result;
            }
            return -1;
    }
    void setVoiceByIndex(NSUInteger index) {
                NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
                AVSpeechSynthesisVoice *oldVoice = currentVoice;
                @try {
                    currentVoice = [voices objectAtIndex:index];
                } @catch(NSException *exception) {
                    currentVoice = oldVoice; //I don't know if it's necessary, just for sure
                }
    }
    private:
    AVSpeechSynthesisVoice *getVoiceObject(NSString *name) {
                NSArray<AVSpeechSynthesisVoice *> *voices = [AVSpeechSynthesisVoice speechVoices];
                for(AVSpeechSynthesisVoice *v in voices) {
                    if([v.name isEqualToString:name]) return v;
                }
                return nil;
    }
};

TTSVoice::TTSVoice() : impl(new Impl()), RefCount(1) {}
TTSVoice::TTSVoice(const std::string& name) : impl(new Impl(name)) {}
TTSVoice::~TTSVoice() { delete impl; }

bool TTSVoice::speak(const std::string& text, bool interrupt) {
    return impl->speak(text, interrupt);
}

bool TTSVoice::speakWait(const std::string& text, bool interrupt) {
    return impl->speakWait(text, interrupt);
}

bool TTSVoice::pauseSpeech() {
    return impl->pauseSpeech();
}

bool TTSVoice::stopSpeech() {
    return impl->stopSpeech();
}

std::string TTSVoice::getCurrentVoice() const {
    return impl->getCurrentVoice();
}
CScriptArray* TTSVoice::getAllVoices() const {
    return impl->getAllVoices();
}
CScriptArray* TTSVoice::getVoicesByLanguage(const std::string& language) const {
    return impl->getVoicesByLanguage(language);
}

void TTSVoice::setVoiceByLanguage(const std::string& language) {
    impl->selectVoiceByLanguage(language);
}
void TTSVoice::setVoiceByName(const std::string& name) {
    impl->selectVoiceByName(name);
}
float TTSVoice::getRate() const { return impl->rate; }
float TTSVoice::getPitch() const { return impl->pitch; }
float TTSVoice::getVolume() const { return impl->volume; }
bool TTSVoice::isPaused() const { return impl->isPaused(); }
bool TTSVoice::isSpeaking() const { return impl->isSpeaking(); }
void TTSVoice::setRate(float rate) { impl->rate = rate; }
void TTSVoice::setPitch(float pitch) { impl->pitch = pitch; }
void TTSVoice::setVolume(float volume) { impl->volume = volume; }
std::string TTSVoice::getCurrentLanguage() const {
    return impl->getCurrentLanguage();
}
uint64_t TTSVoice::getVoicesCount() const {
    return impl->getVoicesCount();
}

int TTSVoice::getVoiceIndex(const std::string& name) const {
    return impl->getVoiceIndex(name);
}

void TTSVoice::setVoiceByIndex(uint64_t index) {
    return impl->setVoiceByIndex(index);
}

void TTSVoice::init() {
    asAtomicInc(RefCount);
}

void TTSVoice::deinit() {
    if(asAtomicDec(RefCount) < 1) {
        delete impl;
        impl = nullptr;
        delete this;
        
    }
}

TTSVoice* init() {
    return new TTSVoice;
}

TTSVoice* initWithName(const std::string& name) {
    return new TTSVoice(name);
}
