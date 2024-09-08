package com.samtupy.nvgt;

import android.content.Context;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.accessibilityservice.AccessibilityServiceInfo;
import java.util.List;
import org.libsdl.app.SDL;

public class TTS {
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
		AccessibilityEvent accessibilityEvent = new AccessibilityEvent();
		accessibilityEvent.setEventType(AccessibilityEvent.TYPE_ANNOUNCEMENT);
		accessibilityEvent.getText().add(text);
		if (interrupt) accessibilityManager.interrupt();
		accessibilityManager.sendAccessibilityEvent(accessibilityEvent);
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
