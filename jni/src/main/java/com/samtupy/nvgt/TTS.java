package com.samtupy.nvgt;

import android.content.Context;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.accessibilityservice.AccessibilityServiceInfo;
import java.util.List;
import org.libsdl.app.SDL;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import java.util.Locale;
import android.speech.tts.Voice;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.Optional;

public class TTS {
	private static String AvoidDuplicateSpeechHack; // Talkback unfortunately sets a flag that causes speech messages to not always be spoken over again in announcement events when the same message is repeated, we work around it by appending a changing number of spaces to the message and this variable stores those.
	private TextToSpeech tts;
	private float ttsPan = 0.0;
	private float ttsVolume = 1.0;
	private float ttsRate = 1.0;
	private float ttsPitch = 1.0;

	public static boolean isScreenReaderActive() {
		Context context = SDL.getContext();
		AccessibilityManager am = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (am != null && am.isEnabled()) {
			List<AccessibilityServiceInfo> serviceInfoList = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_SPOKEN);
			if (!serviceInfoList.isEmpty())
				return true;
		}
		return false;
	}

	public static String screenReaderDetect() {
		Context context = SDL.getContext();
		AccessibilityManager am = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (am != null && am.isEnabled()) {
			List<AccessibilityServiceInfo> serviceInfoList = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_SPOKEN);
			if (serviceInfoList.isEmpty()) return "";
			return serviceInfoList.get(0).getId();
		}
		return "";
	}

	public static boolean screenReaderSpeak(String text, boolean interrupt) {
		Context context = SDL.getContext();
		AccessibilityManager accessibilityManager = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (accessibilityManager == null) return false;
		if (interrupt) accessibilityManager.interrupt();
		AccessibilityEvent e = new AccessibilityEvent();
		e.setEventType(AccessibilityEvent.TYPE_ANNOUNCEMENT);
		e.setPackageName(context.getPackageName());
		e.getText().add(text + AvoidDuplicateSpeechHack);
		AvoidDuplicateSpeechHack += " ";
		if (AvoidDuplicateSpeechHack.length() > 20) AvoidDuplicateSpeechHack = "";
		accessibilityManager.sendAccessibilityEvent(e);
		return true;
	}

	public static boolean screenReaderSilence() {
		Context context = SDL.getContext();
		AccessibilityManager accessibilityManager = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (accessibilityManager == null) return false;
		accessibilityManager.interrupt();
		return true;
	}

	public TTS() {
		Context context = SDL.getContext();
		tts = new TextToSpeech(context, new OnInitListener() {
			@Override
			public void onInit(int status) {
				if (status == TextToSpeech.SUCCESS) {
					this.isTTSInitialized = true;
					tts.setLanguage(Locale.getDefault());
					tts.setPitch(1.0);
					tts.setSpeechRate(1.0);
				} else {
					this.isTTSInitialized = false;
				}
			}
		});
	}

	public boolean isActive() {
		return this.isTTSInitialized;
	}

	public boolean isSpeaking() {
		if (tts != null) {
			return tts.isSpeaking();
		}
		return false;
	}

	public boolean speak(String text, boolean interrupt) {
		if (isActive()) {
			if (interrupt) {
				tts.stop();
			}
			Bundle params = new Bundle();
			params.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, ttsVolume);
			params.putFloat(TextToSpeech.Engine.KEY_PARAM_PAN, ttsPan);
			if (text.length() > tts.getMaxSpeechInputLength()) {
				return false;
			}
			return tts.speak(text, TextToSpeech.QUEUE_ADD, params, null) == TextToSpeech.SUCCESS;
		}
		return false;
	}

	public boolean silence() {
		return isActive() ? tts.stop() == TextToSpeech.SUCCESS : false;
	}

	public String getVoice() {
		return isActive() ? tts.getVoice().getName() : null;
	}

	public Boolean setRate(float rate) {
		if (isActive()) {
			if (tts.setSpeechRate(rate) == TextToSpeech.SUCCESS) {
				ttsRate = rate;
				return true;
			}
		}
		return false;
	}

	public Boolean setPitch(float pitch) {
		if (isActive()) {
			if (tts.setPitch(pitch) == TextToSpeech.SUCCESS) {
				ttsPitch = pitch;
				return true;
			}
		}
		return false;
	}

	public void setPan(float pan) {
		ttsPan = pan;
	}

	public void setVolume(float volume) {
		ttsVolume = volume;
	}

	@override
	public void finalize() {
		if (tts != null && isActive()) {
			tts.shutdown();
		}
	}

	public List<String> getVoices() {
		return (tts != null && tts.isActive()) ? tts.getVoices().stream().map(Voice::getName).collect(Collectors.toList()) : null;
	}

	public Boolean setVoice(String name) {
		if (tts != null && isActive()) {
			Set<Voice> voices = tts.getVoices();
			Optional<Voice> desiredVoice = voices.stream().filter(voice -> voice.getName().equals(desiredVoiceName)).findFirst();
			if (desiredVoice.isPresent()) {
				return tts.setVoice(desiredVoice.get()) == TextToSpeech.SUCCESS;
			} else {
				return false;
			}
		} else {
			return false;
	}

	public int getMaxSpeechInputLength() {
		return (tts != null && isActive()) ? tts.getMaxSpeechInputLength() : 0;
	}

	public float getRate() {
		return ttsRate;
	}

	public float getPitch() {
		return ttsPitch;
	}

	public float getVolume() {
		return ttsVolume;
	}

	public float getPan() {
		return ttsPan;
	}
}
