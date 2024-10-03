package com.samtupy.nvgt;

import android.content.Context;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.accessibilityservice.AccessibilityServiceInfo;
import java.util.List;
import org.libsdl.app.SDL;

public class TTS {
	static String AvoidDuplicateSpeechHack = ""; // Talkback unfortunately sets a flag that causes speech messages to not always be spoken over again in announcement events when the same message is repeated, we work around it by appending a changing number of spaces to the message and this variable stores those.
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
}
