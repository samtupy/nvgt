package com.samtupy.nvgt;

import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.AudioAttributes;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.speech.tts.UtteranceProgressListener;
import android.speech.tts.Voice;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import java.io.File;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.ArrayList;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import org.libsdl.app.SDL;

public class TTS {
	// First the static screen reader methods.
	static String AvoidDuplicateSpeechHack = ""; // Talkback unfortunately sets a flag that causes speech messages to not always be spoken over again in announcement events when the same message is repeated, we work around it by appending a changing number of spaces to the message and this variable stores those.
	public static boolean isScreenReaderActive() {
		Context context = SDL.getContext();
		AccessibilityManager am = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		// Check for TouchExploration to avoid false positives from password managers/antivirus
		if (am != null && am.isEnabled() && am.isTouchExplorationEnabled()) {
			List<AccessibilityServiceInfo> serviceInfoList = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_SPOKEN);
			if (!serviceInfoList.isEmpty()) return true;
		}
		return false;
	}

	public static String screenReaderDetect() {
		Context context = SDL.getContext();
		AccessibilityManager am = (AccessibilityManager) context.getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (am != null && am.isEnabled() && am.isTouchExplorationEnabled()) {
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

	public static List<String> getEnginePackages() {
		Context context = SDL.getContext();
		try {
			TextToSpeech tempTts = new TextToSpeech(context, status -> {});
			List<TextToSpeech.EngineInfo> engines = tempTts.getEngines();
			List<String> packages = new ArrayList<>();
			if (engines != null) {
				for (TextToSpeech.EngineInfo engine : engines) packages.add(engine.name);
			}
			tempTts.shutdown();
			return packages;
		} catch (Exception e) {
			return new ArrayList<>();
		}
	}

	// Then, the instantiable object that interfaces directly with the Android TextToSpeech system.
	private TextToSpeech tts;
	private float ttsPan = 0.0f;
	private float ttsVolume = 1.0f;
	private float ttsRate = 1.0f;
	private float ttsPitch = 1.0f;
	private boolean isTTSInitialized = false;
	private CountDownLatch isTTSInitializedLatch;
	private String enginePackage;

	// PCM synthesis fields
	private ByteArrayOutputStream pcmAudioBuffer;
	private CountDownLatch pcmSynthesisLatch;
	private int pcmSampleRate;
	private int pcmAudioFormat;
	private int pcmChannelCount;
	private boolean pcmSynthesisSuccessful;
	private String currentPcmUtteranceId;

	// Voice management fields
	private List<Voice> availableVoices;
	private int currentVoiceIndex;
	public TTS(String enginePkg) {
		Context context = SDL.getContext();
		enginePackage = enginePkg;
		isTTSInitializedLatch = new CountDownLatch(1);
		OnInitListener listener = new OnInitListener() {
			@Override
			public void onInit(int status) {
				if (status == TextToSpeech.SUCCESS) {
					isTTSInitialized = true;
					try {
						tts.setLanguage(Locale.getDefault());
					} catch (Exception e) {}
					tts.setPitch(1.0f);
					tts.setSpeechRate(1.0f);
					AudioAttributes audioAttributes = new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build();
					tts.setAudioAttributes(audioAttributes);
					initializeVoices();
					setupPcmListener();
				} else
					isTTSInitialized = false;
				isTTSInitializedLatch.countDown();
			}
		};
		tts = enginePackage != null? new TextToSpeech(context, listener, enginePackage) : new TextToSpeech(context, listener);
		try {
			// Changed from 1000ms to 10 seconds to fix race condition on slower devices/cold starts
			isTTSInitializedLatch.await(10, TimeUnit.SECONDS);
		} catch (InterruptedException e) {}
	}
	public TTS() { this(null); }

	public boolean isActive() { return this.isTTSInitialized; }
	public boolean isSpeaking() { return isActive()? tts.isSpeaking() : false; }

	public boolean speak(String text, boolean interrupt) {
		if (!isActive()) return false;
		Bundle params = new Bundle();
		params.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, ttsVolume);
		params.putFloat(TextToSpeech.Engine.KEY_PARAM_PAN, ttsPan);
		if (text.length() > tts.getMaxSpeechInputLength()) return false;
		return tts.speak(text, interrupt? TextToSpeech.QUEUE_FLUSH : TextToSpeech.QUEUE_ADD, params, null) == TextToSpeech.SUCCESS;
	}
	public boolean silence() { return isActive()? tts.stop() == TextToSpeech.SUCCESS : false; }
	public String getVoice() { 
		if (!isActive() || tts.getVoice() == null) return null;
		return tts.getVoice().getName(); 
	}

	public boolean setRate(float rate) {
		if (!isActive()) return false;
		if (tts.setSpeechRate(rate) == TextToSpeech.SUCCESS) {
			ttsRate = rate;
			return true;
		}
		return false;
	}
	public boolean setPitch(float pitch) {
		if (!isActive()) return false;
		if (tts.setPitch(pitch) == TextToSpeech.SUCCESS) {
			ttsPitch = pitch;
			return true;
		}
		return false;
	}
	public void setPan(float pan) { ttsPan = pan; }
	public void setVolume(float volume) { ttsVolume = volume; }

	@Override
	protected void finalize() throws Throwable {
		if (isActive())
			tts.shutdown();
		super.finalize();
	}

	public List<String> getVoices() { 
		if (!isActive() || tts.getVoices() == null) return new ArrayList<>();
		return tts.getVoices().stream().map(Voice::getName).collect(Collectors.toList()); 
	}
	public boolean setVoice(String name) {
		if (!isActive()) return false;
		Set<Voice> voices = tts.getVoices();
		if (voices == null) return false;
		Optional<Voice> desiredVoice = voices.stream().filter(voice -> voice.getName().equals(name)).findFirst();
		if (desiredVoice.isPresent()) return tts.setVoice(desiredVoice.get()) == TextToSpeech.SUCCESS;
		return false;
	}
	public int getMaxSpeechInputLength() { return isActive()? tts.getMaxSpeechInputLength() : 0; }
	public float getRate() { return ttsRate; }
	public float getPitch() { return ttsPitch; }
	public float getVolume() { return ttsVolume; }
	public float getPan() { return ttsPan; }

	// Initialize voice management
	private void initializeVoices() {
		if (!isActive()) return;
		availableVoices = new ArrayList<>();
		try {
			Set<Voice> voices = tts.getVoices();
			if (voices != null) {
				for (Voice voice : voices) {
					if (!voice.isNetworkConnectionRequired() && !voice.getFeatures().contains("notInstalled"))
						availableVoices.add(voice);
				}
			}
			currentVoiceIndex = 0;
			if (!availableVoices.isEmpty() && tts.getVoice() != null) {
				Voice currentVoice = tts.getVoice();
				for (int i = 0; i < availableVoices.size(); i++) {
					if (availableVoices.get(i).getName().equals(currentVoice.getName())) {
						currentVoiceIndex = i;
						break;
					}
				}
			}
		} catch (Exception e) {}
	}

	// Set up permanent UtteranceProgressListener for PCM synthesis
	private void setupPcmListener() {
		tts.setOnUtteranceProgressListener(new UtteranceProgressListener() {
			@Override
			public void onStart(String utteranceId) {}
			@Override
			public void onBeginSynthesis(String utteranceId, int sampleRateInHz, int audioFormat, int channelCount) {
				if (currentPcmUtteranceId != null && currentPcmUtteranceId.equals(utteranceId)) {
					pcmSampleRate = sampleRateInHz;
					pcmAudioFormat = audioFormat;
					pcmChannelCount = channelCount;
				}
			}

			@Override
			public void onAudioAvailable(String utteranceId, byte[] audio) {
				if (currentPcmUtteranceId != null && currentPcmUtteranceId.equals(utteranceId) && pcmAudioBuffer != null) {
					try {
						pcmAudioBuffer.write(audio);
					} catch (IOException e) {
						pcmSynthesisSuccessful = false;
					}
				}
			}

			@Override
			public void onDone(String utteranceId) {
				if (currentPcmUtteranceId != null && currentPcmUtteranceId.equals(utteranceId)) {
					pcmSynthesisSuccessful = true;
					new File(SDL.getContext().getCacheDir(), "nvgt_speech.wav").delete();
					if (pcmSynthesisLatch != null) {
						pcmSynthesisLatch.countDown();
					}
				}
			}

			@Override
			public void onError(String utteranceId) {
				if (currentPcmUtteranceId != null && currentPcmUtteranceId.equals(utteranceId)) {
					pcmSynthesisSuccessful = false;
					new File(SDL.getContext().getCacheDir(), "nvgt_speech.wav").delete();
					if (pcmSynthesisLatch != null) {
						pcmSynthesisLatch.countDown();
					}
				}
			}
		});
	}

	public int getVoiceCount() { return isActive() && availableVoices != null? availableVoices.size() : 0; }
	public String getVoiceName(int index) {
		if (!isActive() || availableVoices == null || index < 0 || index >= availableVoices.size()) return "";
		return availableVoices.get(index).getName();
	}
	public String getVoiceLanguage(int index) {
		if (!isActive() || availableVoices == null || index < 0 || index >= availableVoices.size()) return "";
		Locale locale = availableVoices.get(index).getLocale();
		if (locale == null) return "";
		String lang = locale.getLanguage();
		String country = locale.getCountry();
		return country.isEmpty()? lang.toLowerCase(Locale.ROOT) : (lang + "-" + country).toLowerCase(Locale.ROOT);
	}
	public boolean setVoiceByIndex(int index) {
		if (!isActive() || availableVoices == null || index < 0 || index >= availableVoices.size()) return false;
		Voice voice = availableVoices.get(index);
		if (tts.setVoice(voice) == TextToSpeech.SUCCESS) {
			currentVoiceIndex = index;
			return true;
		}
		return false;
	}
	public int getCurrentVoiceIndex() { return currentVoiceIndex; }

	// Synthesize text to PCM audio buffer
	public byte[] speakPcm(String text) {
		if (!isActive() || text.isEmpty()) return null;
		if (text.length() > tts.getMaxSpeechInputLength()) return null;

		// Prepare for PCM synthesis
		pcmAudioBuffer = new ByteArrayOutputStream();
		pcmSynthesisLatch = new CountDownLatch(1);
		pcmSynthesisSuccessful = false;
		pcmSampleRate = 0;
		pcmAudioFormat = 0;
		pcmChannelCount = 0;

		// Create utterance ID and set it as current
		currentPcmUtteranceId = "nvgtts_" + System.currentTimeMillis();

		// Create synthesis parameters
		Bundle params = new Bundle();
		params.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, ttsVolume);
		params.putFloat(TextToSpeech.Engine.KEY_PARAM_PAN, ttsPan);
		params.putInt(TextToSpeech.Engine.KEY_PARAM_STREAM, AudioManager.STREAM_MUSIC);

		// Start synthesis - using speak with synthesis callbacks
		int result = tts.synthesizeToFile(text, params, new File(SDL.getContext().getCacheDir(), "nvgt_speech.wav"), currentPcmUtteranceId);
		if (result != TextToSpeech.SUCCESS) {
			currentPcmUtteranceId = null;
			return null;
		}

		// Wait for synthesis to complete
		try {
			pcmSynthesisLatch.await(10000, TimeUnit.MILLISECONDS); // 10 second timeout
		} catch (InterruptedException e) {
			currentPcmUtteranceId = null;
			return null;
		}

		// Clean up and return the audio data if successful
		currentPcmUtteranceId = null;
		if (pcmSynthesisSuccessful) {
			return pcmAudioBuffer.toByteArray();
		}
		return null;
	}

	public int getPcmSampleRate() { return pcmSampleRate; }
	public int getPcmAudioFormat() { return pcmAudioFormat; }
	public int getPcmChannelCount() { return pcmChannelCount; }
}
