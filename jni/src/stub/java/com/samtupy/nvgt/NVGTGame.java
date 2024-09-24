package com.samtupy.nvgt;
import org.libsdl.app.SDLActivity;
public class NVGTGame extends SDLActivity {
	protected String getMainSharedObject() {
		return getContext().getApplicationInfo().nativeLibraryDir + "/libgame.so";
	}
	protected String[] getLibraries() {
		return new String[] {"SDL3", "game"};
	}
}
