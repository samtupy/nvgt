/* macos.mm - code built only on the MacOS platform
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

#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#include <string>
#include <Poco/Event.h>
#include <Poco/Mutex.h>
#include <Poco/Thread.h>

extern NSWindow* g_OSWindowHandle; // Voice over speech unfortunately only works from a window created by our application it seems.
bool voice_over_announce(const std::string& message) {
	if (!g_OSWindowHandle) return false;
	NSString* nsmsg = [NSString stringWithUTF8String:message.c_str()];
	NSAccessibilityPostNotificationWithUserInfo(g_OSWindowHandle, NSAccessibilityAnnouncementRequestedNotification, @ {NSAccessibilityAnnouncementKey: nsmsg, NSAccessibilityPriorityKey: @(NSAccessibilityPriorityHigh)});
	return [NSApp keyWindow] == g_OSWindowHandle;
}

std::string speech_text = "";
Poco::FastMutex speech_text_mutex;
Poco::Event speech_new_event;
Poco::Thread speech_thread;
bool speech_shutdown = false;
// So this really sucks, and if someone can come along and make this nonsense unneeded, it would be very very appreciated. So the apple documentation taunts us telling us that we can pass speech notification priorities to NSAccessibilityPostNotificationWithUserInfo to control speech interrupt, and quite simply it doesn't work. While this doesn't at all make non-interrupting speech events actually work, it does make it possible to queue multiple speak calls together with only the first being interrupting.
void vo_speech_thread(void* extra) {
	speech_new_event.wait(); // When new text is spoken this event will become set.
	if (speech_shutdown) {
		speech_shutdown = false;
		return; // The event will also become set when it's time to terminate this thread.
	}
	while (speech_new_event.tryWait(10)) continue; // The entire point of this system is to rig a tiny delay so that other parts of the speech sequence can queue before speaking. Poco::Event::tryWait returns true if the event was signaled before the 10ms elapsed, meaning new text was added and we should restart the timer.
	Poco::FastMutex::ScopedLock exclusive(speech_text_mutex);
	voice_over_announce(speech_text);
	speech_text = ""; // Then the loop restarts and we wait for new speech again.
}

bool voice_over_is_running() {
	return [[NSWorkspace sharedWorkspace] isVoiceOverEnabled];
}

bool voice_over_speak(const std::string& message, bool interrupt) {
	if ([[NSWorkspace sharedWorkspace] isVoiceOverEnabled] == NO) return false; // I hesitate here, exactly how quick is this query?
	if (!speech_thread.isRunning()) speech_thread.start(vo_speech_thread);
	Poco::FastMutex::ScopedLock exclusive(speech_text_mutex);
	if (interrupt || speech_text == "") speech_text = message;
	else {
		speech_text += " . "; // This is likely not going to work on all punctuation verbocity, look there is only so much I can do.
		speech_text += message;
	}
	speech_new_event.set();
	return [NSApp keyWindow] == g_OSWindowHandle; // The window being active is the closest aproximation to a success value we're going to get.
}

// Voiceover takes a second to detect the app window after it is shown even though the system has keyboard input instantly. Can we fix that with an accessibility notification? I have no idea what I'm doing here.
void voice_over_window_created() {
	NSAccessibilityPostNotification(g_OSWindowHandle, NSAccessibilityApplicationActivatedNotification);
	NSAccessibilityPostNotification(g_OSWindowHandle, NSAccessibilityApplicationShownNotification);
	NSAccessibilityPostNotification(g_OSWindowHandle, NSAccessibilityWindowCreatedNotification);
	NSAccessibilityPostNotification(g_OSWindowHandle, NSAccessibilityFocusedWindowChangedNotification);
}

void voice_over_speech_shutdown() {
	speech_shutdown = true;
	speech_new_event.set();
}

// The following code was originally taken from https://github.com/hammerspoon/hammerspoon under an MIT license, but has been heavily trimmed/modified for our simpler needs and basically consists of system API calls.
std::string apple_input_box(const std::string& title, const std::string& message, const std::string& default_value, bool secure, bool readonly) {
	NSAlert* alert = [[NSAlert alloc] init];
	[alert setMessageText:[NSString stringWithUTF8String:title.c_str()]];
	[alert setInformativeText:[NSString stringWithUTF8String:message.c_str()]];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[[alert.buttons objectAtIndex:0] setKeyEquivalent:@"\r"]; // Return
	[[alert.buttons objectAtIndex:1] setKeyEquivalent:@"\033"]; // Escape
	NSTextField* input;
	if (secure) input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
	else input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
	[input setStringValue:[NSString stringWithUTF8String:default_value.c_str()]];
	input.editable = !readonly;
	[alert setAccessoryView:input];
	[[alert window] setInitialFirstResponder:input]; // Focus on text input.
	NSInteger result = [alert runModal];
	if (result == NSAlertFirstButtonReturn) return [[input stringValue] UTF8String];
	else if (result == NSAlertSecondButtonReturn) return "\xff"; // nvgt value for cancel for the moment.
	return "\xff"; // Either an error or we can't determine what was pressed. Should we throw an exception or something?
}

void nextMacInputSource() {
	CFArrayRef inputSources = TISCreateInputSourceList(NULL, false);
	TISInputSourceRef currentInput = TISCopyCurrentKeyboardInputSource();
	NSInteger count = CFArrayGetCount(inputSources);
	NSInteger currentIndex = -1;
	for(int i=0; i<count; i++) {
		TISInputSourceRef k = (TISInputSourceRef)CFArrayGetValueAtIndex(inputSources, i);
		if(CFEqual(k, currentInput)) {
			currentIndex = i;
			break;	
		}
	}
	if(currentIndex==-1) {
	CFRelease(currentInput);
	CFRelease(inputSources);
	return;
	}
	NSInteger nextIndex = (currentIndex+1)%count;
	TISInputSourceRef nextInput = (TISInputSourceRef)CFArrayGetValueAtIndex(inputSources, nextIndex);
	TISSelectInputSource(nextInput);
	CFRelease(currentInput);
	CFRelease(inputSources);
}