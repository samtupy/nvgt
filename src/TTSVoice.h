//
//  TTSVoice.h
//  NVGTAVTTSVoice
//
//  Created by Gruia Chiscop on 6/6/24.
//
#pragma once
#include <string>
#include <vector>
#include "angelscript.h"
#include <scriptarray.h>
class TTSVoice {
public:
    TTSVoice();
    TTSVoice(const std::string& name);
~TTSVoice();
    void init();
    void deinit();

    bool speak(const std::string& text, bool interrupt);
    bool speakWait(const std::string& text, bool interrupt);
    bool stopSpeech();
    bool pauseSpeech();
    CScriptArray* getAllVoices() const;
    CScriptArray* getVoicesByLanguage(const std::string& language) const;
    std::string getCurrentVoice() const;
    bool isSpeaking() const;
    bool isPaused() const;
    void setRate(float rate);
    float getRate() const;
    void setVolume(float volume);
    float getVolume() const;
    void setPitch(float pitch);
    float getPitch() const;
    void setVoiceByName(const std::string& name);
    void setVoiceByLanguage(const std::string& language);
    std::string getCurrentLanguage() const;
    uint64_t getVoicesCount() const;
    int getVoiceIndex(const std::string& name) const;
    void setVoiceByIndex(uint64_t index);
private:
    class Impl;
    Impl* impl;
    int RefCount;
};

void RegisterAVTTSVoice(asIScriptEngine* engine);
TTSVoice* init();
TTSVoice* initWithName(const std::string& name);