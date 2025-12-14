package com.samtupy.nvgt;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.text.method.ScrollingMovementMethod;
import android.view.ViewGroup;
import android.widget.*;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.io.StringWriter;
import java.io.PrintWriter;

public final class DialogUtils {
	public static String getExceptionInfo(Throwable t) {
		if (t == null) return "Unknown Error";
		StringWriter sw = new StringWriter();
		PrintWriter pw = new PrintWriter(sw);
		t.printStackTrace(pw);
		return sw.toString();
	}

	public static CompletableFuture<String> inputBox(Activity activity, String caption, String prompt, String defaultText) {
		Objects.requireNonNull(activity, "activity");
		Objects.requireNonNull(caption, "caption");
		Objects.requireNonNull(prompt, "prompt");
		final String initial = defaultText != null ? defaultText : "";
		final CompletableFuture<String> result = new CompletableFuture<>();
		activity.runOnUiThread(() -> {
			EditText edit = new EditText(activity);
			edit.setSingleLine(true);
			edit.setText(initial);
			edit.setSelection(initial.length());
			new AlertDialog.Builder(activity)
				.setTitle(caption)
				.setMessage(prompt)
				.setView(edit)
				.setCancelable(true)
				.setPositiveButton("OK", (dlg, which) ->
					result.complete(edit.getText().toString())
				)
				.setNegativeButton("Cancel", (dlg, which) ->
					result.complete("\u00FF")
				)
				.setOnCancelListener(dlg ->
					result.complete("\u00FF")
				)
				.show();
		});
		return result;
	}


/**
	 * Displays a modal information dialog with title, prompt, and multi-line text.
	 * Resolves when the user taps "Close".
	 */

	public static CompletableFuture<Void> infoBox(Activity activity, String caption, String prompt, String text) {
		Objects.requireNonNull(activity, "activity");
		Objects.requireNonNull(caption, "caption");
		Objects.requireNonNull(prompt, "prompt");
		Objects.requireNonNull(text, "text");
		final CompletableFuture<Void> done = new CompletableFuture<>();
		activity.runOnUiThread(() -> {
			LinearLayout container = new LinearLayout(activity);
			container.setOrientation(LinearLayout.VERTICAL);
			int padding = (int)(16 * activity.getResources().getDisplayMetrics().density);
			container.setPadding(padding, padding, padding, padding);
			TextView lbl = new TextView(activity);
			lbl.setText(prompt);
			lbl.setTypeface(Typeface.DEFAULT_BOLD);
			container.addView(lbl, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
			ScrollView scroller = new ScrollView(activity);
			TextView tv = new TextView(activity);
			tv.setText(text);
			tv.setMovementMethod(new ScrollingMovementMethod());
			scroller.addView(tv, new ScrollView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
			container.addView(scroller, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1.0f));
			new AlertDialog.Builder(activity)
				.setTitle(caption)
				.setView(container)
				.setCancelable(true)
				.setPositiveButton("Close", (dlg, which) -> {
					done.complete(null);
				})
				.setOnCancelListener(dlg -> done.complete(null))
				.show();
		});
		return done;
	}

	public static String inputBoxSync(Activity activity, String caption, String prompt, String defaultText) {
		try {
			return inputBox(activity, caption, prompt, defaultText).get();
		} catch (Exception e) {
			return "\u00FF";
		}
	}

	public static void infoBoxSync(Activity activity, String caption, String prompt, String text) {
		try {
			infoBox(activity, caption, prompt, text).get();
		} catch (Exception ignored) { }
	}
}
