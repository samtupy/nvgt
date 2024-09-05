/* bundling.cpp - Routines for creating final application packages or bundles on various platforms
 * On Android, this allows games to be compiled to .apk packages.
 * on MacOS and IOS, this will allow .app bundles to be generated.
 * on Windows, this will add version information to the executable and optionally copy libraries and other assets into a package that can be installed/zipped/whatever.
 * It should be understood that these bundling facilities in particular are not standalone and may have limited functionality when compiling on platforms other than their intended targets. For example the NVGT user needs the android development tools to bundle an Android app, it's best to bundle a .app on a mac because nvgt can then go as far as to create a .dmg for you which is not possible on other platforms etc.
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

// This entire module is only needed assuming that NVGT is not being compiled as a stub, and also assuming that the runner application is not being built on mobile. It's perfectly find to just not build bundling.cpp at all as long as NVGT_STUB is defined, but lets not error or risk including code in case of inclusion into a stub so that we can laisily feed the build system a wildcard to the src directory.
#include "xplatform.h"
#if !defined(NVGT_STUB) && !defined(NVGT_MOBILE)
#include <Poco/BinaryReader.h>
#include <Poco/BinaryWriter.h>
#include <Poco/Clock.h>
#include <Poco/Environment.h>
#include <Poco/File.h>
#include <Poco/FileStream.h>
#include <Poco/Format.h>
#include <Poco/Glob.h>
#include <Poco/Path.h>
#include <Poco/PipeStream.h>
#include <Poco/Process.h>
#include <Poco/StreamCopier.h>
#include <Poco/String.h>
#include <Poco/TemporaryFile.h>
#include <Poco/Timestamp.h>
#include <Poco/Util/Application.h>
#include <Poco/Zip/Compress.h>
#include <Poco/Zip/Decompress.h>
#include <plist/plist.h>
#ifdef _WIN32
#include <vs_version.h>
#endif
#include "bundling.h"
#include "misc_functions.h" // parse_float
#include "nvgt.h"
#ifndef NVGT_USER_CONFIG
	#include "nvgt_config.h"
#else
	#include "../user/nvgt_config.h"
#endif
#include "pack.h" // write_embedded_packs
#include "UI.h"
using namespace std;
using namespace Poco;

// Helper function to run a shell command that returns true if that command returns 0, false otherwise. Specifically intended for programatic use, this makes no attempt to print output or errors from the given command to the real stdout stream and instead captures all output for use in our program.
bool system_command(const std::string& command, const Process::Args& args, const std::string& initial_directory, string& std_out, string& std_err) {
	Pipe p_out, p_err;
	int rc;
	if (initial_directory.empty()) rc = Process::wait(Process::launch(command, args, nullptr, &p_out, &p_err));
	else rc = Process::wait(Process::launch(command, args, initial_directory, nullptr, &p_out, &p_err));
	if (rc < 0) return false;
	StreamCopier::copyToString(*SharedPtr<PipeInputStream>(new PipeInputStream(p_out)), std_out);
	StreamCopier::copyToString(*SharedPtr<PipeInputStream>(new PipeInputStream(p_err)), std_err);
	return rc == 0;
}
bool system_command(const std::string& command, const Process::Args& args, string& std_out, string& std_err) {
	return system_command(command, args, "", std_out, std_err);
}
bool system_command(const string& command, const Process::Args& args = {}) {
	string std_out, std_err;
	return system_command(command, args, std_out, std_err);
}

class nvgt_compilation_output_impl : public virtual nvgt_compilation_output {
	string platform, stub, input_file, output_file;
	string stub_location, error_text;
	UInt64 stub_size;
	Path outpath;
	void error(const exception& exc, const std::string& error) {
		error_text = error;
		throw;
	}
public:
	nvgt_compilation_output_impl(const string& input_file) : input_file(input_file), platform(g_platform), stub(g_stub), stub_size(0), config(Util::Application::instance().config()) {}
	const string& get_error_text() {
		return error_text;
	}
	const string& get_input_file() {
		return input_file;
	}
	const string& get_output_file() {
		return output_file;
	}
	void prepare() {
		Path stubpath = config.getString("application.dir");
		stubpath.pushDirectory("stub");
		xplatform_correct_path_to_stubs(stubpath);
		alter_stub_path(stubpath);
		stubpath = format("%snvgt_%s%s.bin", stubpath.toString(), platform, (stub != "" ? string("_") + stub : ""));
		outpath = config.getString("build.output_basename", Path(input_file).setExtension("").toString());
		alter_output_path(outpath);
		try {
			copy_stub(stubpath, outpath);
		} catch(exception& e) { error(e, format("failed to copy %s to %s", stubpath.toString(), outpath.toString())); }
		open_output_stream(outpath);
		output_file = outpath.toString();
		fs.seekp(0, std::ios::end);
	}
	void write_payload(const unsigned char* payload, unsigned int size) {
		if (!fs.good()) error(Exception("stream is not ready"), "error writing payload");
		BinaryWriter bw(fs);
		write_embedded_packs(bw);
		bw.write7BitEncoded(size ^ NVGT_BYTECODE_NUMBER_XOR);
		bw.writeRaw((const char*)payload, size);
	}
	void finalize() {
		if (!fs.good()) return; // This shouldn't be called in this condition!
		finalize_output_stream();
		fs.close();
		finalize_product(outpath);
		output_file = outpath.toString();
	}
	void postbuild() {
		postbuild(outpath);
	}
protected:
	FileStream fs;
	Util::LayeredConfiguration& config;
	string make_product_id() {
		// If the user does not specify a product ID such as com.developer.mygame for platforms that require such a thing, we'll generate one using the script basename.
		string output;
		string bn = Path(get_input_file()).getBaseName();
		for (char i : bn) {
			if (i == '-' || i == '_') continue;
			if (i >= 'A' && i <= 'Z' || i >= 'a' && i <= 'z' || i >= '0' && i <= '9') output += i;
			else output += (output.empty()? "g" : format("%d", int(i)));
		}
		return "com.NVGTUser." + output;
	}
	virtual void alter_stub_path(Path& stubpath) {
		// This method can be overwritten by subclasses to modify the location that stubs are selected from. Throw an exception to abort the compilation.
	}
	virtual void alter_output_path(Path& output_path) {
		// This method can be overwritten by subclasses to change the output location of the final binary containing the byte code. The overwritten method is typically responsible for creating any directories needed unless copy_stub is also overridden in which case it's up to the subclass. Throw an exception to abort the compilation.
	}
	virtual void copy_stub(const Path& stubpath, const Path& outpath) {
		// This base method assumes that the stub is a direct executable for the target platform and should be overridden  whenever this is not the case.
		File(stubpath).copyTo(outpath.toString());
		File(outpath).setExecutable();
	}
	virtual void open_output_stream(const Path& output_path) {
		// This base method just opens the copied stub binary for output and seeks to the location at which bytecode and other information should be written, also setting the stub_size variable. It is the last step of the preparation process prior to NVGT writing it's compiled platform-agnostic game payload. Derived methods will usually call this and then perform any per-platform modifications needed on the copied stub that was just opened.
		fs.open(outpath.toString(), std::ios::in | std::ios::out | std::ios::ate);
		stub_size = fs.size();
	}
	virtual void finalize_output_stream() {
		// This method is called from the public finalize method prior to closing the output stream, the default implementation just writes the stub size to it's current position after bytecode has been written. Subclasses implementing platforms where this is not the case should override this method.
		BinaryWriter(fs) << int(stub_size);
	}
	virtual void finalize_product(Path& outpath) {
		// Subclasses can override this method as a final hook into the bundling process after bytecode has been written to the stub but before build success is reported to the user. If any final packaging steps performed here modify the final output path, update the outpath parameter accordingly so that the correct path of the final product package will be shown to the user.
	}
	virtual void postbuild(const Path& output_path) {
		// This is the very last method called on the bundling object before it is destroyed only assuming the build was successful. It was originally added to support output installation tasks on certain platforms.
	}
};
class nvgt_compilation_output_windows : public nvgt_compilation_output_impl {
	using nvgt_compilation_output_impl::nvgt_compilation_output_impl;
protected:
	void alter_output_path(Path& output_path) override { output_path.setExtension("exe"); }
	void open_output_stream(const Path& output_path) override {
		nvgt_compilation_output_impl::open_output_stream(output_path);
		BinaryReader br(fs);
		BinaryWriter bw(fs);
		// NVGT distributes windows stubs with the first 2 bytes of the PE header modified so that they are not recognised as executables, this avoids an extra AV scan when the stub is copied which may add a few hundred ms to compile times. Fix them now in the copied file.
		fs.seekp(0);
		bw.writeRaw("MZ");
		if (config.hasOption("build.windows_console")) { // The user wants to compile their app without /subsystem:windows
			int subsystem_offset;
			fs.seekg(60); // position of new PE header address.
			br >> subsystem_offset;
			subsystem_offset += 92; // offset in new PE header containing subsystem word. 2 for GUI, 3 for console.
			fs.seekp(subsystem_offset);
			bw << UInt16(3);
		}
	}
	void finalize_output_stream() override {} // Don't write payload offset on this platform.
};
class nvgt_compilation_output_mac : public nvgt_compilation_output_impl {
	SharedPtr<File> workplace_tmp;
	File workplace;
	Path final_output_path;
	int bundle_mode;
	using nvgt_compilation_output_impl::nvgt_compilation_output_impl;
protected:
	void alter_output_path(Path& output_path) override {
		bundle_mode = config.getInt("build.mac_bundle", 2); // 0 no bundle, 1 .app, 2 .dmg/.zip, 3 both .app and .dmg/.zip.
		if (bundle_mode == 2) {
			workplace_tmp = new TemporaryFile();
			workplace = Path(workplace_tmp->path()).append(Path(output_path).makeFile().getFileName()).setExtension("app");
		} else if(bundle_mode > 0) workplace = Path(output_path).makeFile().setExtension("app");
		if (bundle_mode) {
			Path tmp = Path(workplace.path()).append("Contents/MacOS");
			File(tmp).createDirectories();
			tmp.append(output_path.getBaseName()).makeFile();
			final_output_path = output_path;
			output_path = tmp;
		}
	}
	void finalize_product(Path& output_path) override {
		if (!bundle_mode) return; // We are not creating a bundle in this condition.
		string product_name = config.getString("build.product_name", Path(get_input_file()).getBaseName());
		string product_identifier = config.getString("build.product_identifier", make_product_id());
		// Write out info.plist.
		plist_t plist = plist_new_dict();
		plist_dict_set_item(plist, "CFBundleDisplayName", plist_new_string(product_name.c_str()));
		plist_dict_set_item(plist, "CFBundleExecutable", plist_new_string(format("MacOS/%s", output_path.getFileName()).c_str()));
		plist_dict_set_item(plist, "CFBundleIdentifier", plist_new_string(product_identifier.c_str()));
		plist_dict_set_item(plist, "CFBundleInfoDictionaryVersion", plist_new_string("6.0"));
		plist_dict_set_item(plist, "CFBundleName", plist_new_string(product_name.c_str()));
		plist_dict_set_item(plist, "CFBundlePackageType", plist_new_string("APPL"));
		plist_t plist_env_block = plist_new_dict();
		plist_dict_set_item(plist_env_block, "MACOS_BUNDLED_APP", plist_new_string("1"));
		plist_dict_set_item(plist, "LSEnvironment", plist_env_block);
		char* plist_xml;
		uint32_t plist_len;
		if (plist_to_xml(plist, &plist_xml, &plist_len) != PLIST_ERR_SUCCESS) throw Exception("Unable to create info.plist");
		FileOutputStream plist_out(Path(workplace.path()).append("Contents/info.plist").toString());
		plist_out.write(plist_xml, plist_len);
		plist_out.close();
		plist_mem_free(plist_xml);
		plist_free(plist);
		// Now copy shared libraries.
		File frameworks_location = Path(workplace.path()).append("Contents/Frameworks").toString();
		if (frameworks_location.exists()) frameworks_location.remove(true);
		File(get_nvgt_lib_directory(g_platform)).copyTo(frameworks_location.path());
		if (bundle_mode > 1) {
			// On the mac, we can execute the hdiutil command to create a .dmg file. Otherwise, we must create a .zip instead, as it can portably store unix file attributes.
			#ifdef __APPLE__
				string sout, serr;
				File dmg_out = Path(final_output_path).makeFile().setExtension("dmg").toString();
				if (dmg_out.exists()) dmg_out.remove(true);
				if (!system_command("hdiutil", {"create", "-srcfolder", workplace.path(), dmg_out.path()}, sout, serr)) throw Exception(format("Unable to execute hdiutil for .dmg generation: %s", serr));
				output_path = dmg_out.path();
			#else
				File zip_out = Path(final_output_path).makeFile().setExtension("app.zip").toString();
				FileOutputStream zip_out_stream(zip_out.path());
				Zip::Compress zcpr(zip_out_stream, true);
				zcpr.addRecursive(workplace.path());
				Zip::ZipArchive za = zcpr.close();
				output_path = zip_out.path();
			#endif
		} else output_path = workplace.path();
	}
};
class nvgt_compilation_output_android : public nvgt_compilation_output_impl {
	TemporaryFile workplace;
	Path final_output_path, android_jar, apksigner_jar;
	int do_install; // 0 no, 1 ask, 2 always.
	string sign_cert, sign_password;
	using nvgt_compilation_output_impl::nvgt_compilation_output_impl;
	string exe(const std::string& path) {
		return Environment::isWindows()? path + ".exe" : path;
	}
	bool android_sdk_tools_exist(const std::string& path) {
		// This will also set the path to android.jar and apksigner.jar if build tools are found.
		Path located;
		bool found = Path::find(path, exe("zipalign"), located) && (sign_cert.empty() && sign_password.empty() || Path::find(path, exe("java"), located)) && (!do_install || Path::find(path, exe("adb"), located)) && Path::find(path, exe("aapt2"), located);
		if (!found) return false;
		// Since this particular search was last in the Path::find calls above, located now contains a path to aapt2.exe, hopefully we can locate android.jar from it.
		located.setFileName("");
		apksigner_jar = Path(located).append("lib/apksigner.jar");
		float buildtools_version = parse_float(located[located.depth() -1]);
		if (buildtools_version < 1 || located[located.depth() -2] != "build-tools") return false; // Finding android.jar is hopeless given this non-standard location to aapt.
		located.makeParent().makeParent().append("platforms");
		if (File(Path(located).append(format("android-%d", int(buildtools_version)))).exists()) {
			android_jar = located.append(format("android-%d/android.jar", int(buildtools_version)));
			return true;
		}
		throw Exception(format("unable to locate android.jar in %s", located.toString())); // For now we'll assume that the build tools version is the same as the platform directory containing android.jar, if we get reports that this isn't the case for people we can update this code to glob the platforms directory to find one instead.
	}
	void find_android_sdk_tools() {
		sign_cert = config.getString("build.android_signature_cert", "");
		sign_password = config.getString("build.android_signature_password", "");
		do_install = config.getInt("build.android_install", 1);
		string path = config.getString("build.android_path", Environment::get("PATH"));
		if (android_sdk_tools_exist(path)) return;
		string android_home = Path::expand(config.getString("build.android_home", Environment::get("ANDROID_HOME", Environment::get("ANDROID_SDK_HOME", ""))));
		// If we've still failed, maybe we can continue based on some default install locations?
		if (android_home.empty() && Environment::isWindows()) {
			File tmp = Environment::get("ProgramFiles(X86)", "C:\\Program Files (x86)") + "\\Android\\android-sdk"s; // Visual Studio installs android tools here as part of mobile development workload
			if (!tmp.exists()) tmp = Path::dataHome() + "Android\\sdk"; // Android Studio's default sdk install location
			if (tmp.exists()) android_home = tmp.path();
		} else if (android_home.empty() && Environment::os() == POCO_OS_MAC_OS_X) {
			File tmp = Path::expand("~/Library/Android/sdk"); // Android Studio's default sdk install location
			if (tmp.exists()) android_home = tmp.path();
		}
		if (android_home.empty()) throw Exception("unable to locate android development tools");
		// Unfortunately the android SDK might have multiple versions of the build tools, lets try selecting one. For now hopefully the newest, and if that breaks for people we can make it more restrictive.
		set<string> buildtools;
		Glob::glob(android_home + "/build-tools/*/aapt2*", buildtools);
		if (buildtools.empty()) throw Exception(format("Unable to find build-tools for android installation at %s", android_home));
		float selected_version = 0;
		string buildtools_bin;
		for (const std::string& i : buildtools) {
			Path tmp(i);
			tmp.makeParent();
			float ver = parse_float(tmp[tmp.depth() -1]);
			if (ver <= selected_version) continue; // newer already selected
			buildtools_bin = tmp.toString();
			selected_version = ver;
		}
		buildtools_bin += Path::pathSeparator();
		if (do_install) buildtools_bin += Path(android_home).append("platform-tools").toString() + Path::pathSeparator();
		if (!sign_cert.empty() && !sign_password.empty()) {
			Path tmp;
			string java_home = Path::expand(config.getString("build.android_java_home", Environment::get("JAVA_HOME", "")));
			if (!java_home.empty() && !Path::find(path, exe("java"), tmp)) buildtools_bin += Path(java_home).append("bin").toString() + Path::pathSeparator();
		}
		path.insert(0, buildtools_bin);
		Environment::set("PATH", path);
		// For better or worse, we've done what we can and if we haven't found build tools by now the end user must have some real whacked out system or Android SDK installation.
		if (!android_sdk_tools_exist(path)) throw Exception(format("unable to find all Android development tools in detected SDK installation directories %s", buildtools_bin));
	}
protected:
	void alter_output_path(Path& output_path) override {
		final_output_path = output_path;
		final_output_path.setExtension("apk");
		output_path = workplace.path();
		output_path.append("lib/arm64-v8a/libgame.so"); // As soon as we compile for multiple architectures on android we'll change to writing bytecode as some sort of Android app asset rather than part of libgame.so.
	}
	void copy_stub(const Path& stubpath, const Path& outpath) override {
		find_android_sdk_tools();
		workplace.createDirectories();
		FileInputStream fs(stubpath.toString());
		Zip::Decompress zdec(fs, workplace.path());
		zdec.decompressAllFiles();
		fs.close();
	}
	void finalize_product(Path& output_path) override {
		output_path = final_output_path;
		// Here we take the stub components and turn it all into a .apk with the bytecode now embedded. First lets replace the app label.
		string product_name = config.getString("build.product_name", Path(get_input_file()).getBaseName());
		config.setString("build.product_name", product_name);
		string product_identifier = config.getString("build.product_identifier", make_product_id());
		config.setString("build.product_identifier", product_identifier);
		FileInputStream input_manifest(config.getString("build.android_manifest", Path(workplace.path()).append("AndroidManifest.xml").toString()));
		string manifest;
		StreamCopier::copyToString(input_manifest, manifest);
		input_manifest.close();
		replaceInPlace(manifest, "%APP_LABEL%"s, product_name);
		FileOutputStream output_manifest(Path(workplace.path()).append("AndroidManifest.xml").toString());
		output_manifest.write(manifest.c_str(), manifest.size());
		output_manifest.close();
		// Next, run aapt2 to link our modified AndroidManifest.xml and the flat resource files provided by the stub into the beginnings of our APK.
		string sout, serr;
		vector<string> aapt2args = {"link", "-I", android_jar.toString(), "--manifest", "AndroidManifest.xml", "--rename-manifest-package", product_identifier, "", "--rename-resources-package", product_identifier, "--version-code", config.getString("build.product_version_code", format("%u", uint32_t(Timestamp().epochTime()) / 60)), "--version-name", config.getString("build.product_version", "1.0"), "res.zip", "-o", "tmp.apk"};
		if (config.getString("build.android_manifest", "").empty()) aapt2args.push_back("--replace-version");
		if (!system_command(exe("aapt2"), aapt2args, workplace.path(), sout, serr)) throw Exception(format("Failed to run aapt2, %s%s", sout, serr));
		// The initial versions of AndroidManifest.xml and res.zip are no longer needed, get rid of them.
		File(Path(workplace.path()).append("AndroidManifest.xml")).remove();
		File(Path(workplace.path()).append("res.zip")).remove();
		// Now extract the partial APK that aapt2 created on top of our work directory. Aapt2 does have an option to output to a directory as aposed to a zip file which would make this unneeded, but it's broken in versions of the android toolset before a certain point in time that is far too recent for us to safely use the option, especially considering that it breaks on my dev machine.
		FileInputStream tmp_apk(Path(workplace.path()).append("tmp.apk").toString());
		Zip::Decompress zdec(tmp_apk, workplace.path());
		zdec.decompressAllFiles();
		tmp_apk.close();
		File(Path(workplace.path()).append("tmp.apk")).remove();
		// OK! At this point, we have the final contents of our APK file, though extracted and lacking a signature. Lets zip it up, though we can't place the temporary zip file in the directory we want to zip up so we'll need a temporary file.
		TemporaryFile zip_out_location;
		FileOutputStream zip_out(zip_out_location.path());
		Zip::Compress zcpr(zip_out, true);
		zcpr.setStoreExtensions({"arsc"});
		zcpr.addRecursive(workplace.path(), Zip::ZipCommon::CM_AUTO);
		zcpr.close();
		// Now we need to align the zip file we just created using the Android sdk's zipalign tool, this will also be responsible for creating our final actual output file as it's the last operation that cannot be performed in place.
		sout = serr = "";
		if (!system_command(exe("zipalign"), {"-f", "-p", "16", zip_out_location.path(), output_path.toString()}, sout, serr)) throw Exception(format("failed to run zipalign on %s", zip_out_location.path()));
		// If the correct information is provided, lets try to sign the app.
		if (!sign_cert.empty() && !sign_password.empty()) {
			sout = serr = "";
			if (!system_command(exe("java"), {"-jar", apksigner_jar.toString(), "sign", "-ks", sign_cert, "--ks-pass", sign_password, output_path.toString()}, sout, serr)) throw Exception(format("Failed to run apksigner, %s%s", sout, serr));
		}
	}
	void postbuild(const Path& output_path) override {
		bool quiet = config.hasOption("application.quiet") || config.hasOption("application.QUIET");
		string sout, serr;
		if (do_install) {
			if (system_command(exe("adb"), {"shell", "-n"}) && (do_install == 2 || quiet ||question("install app", "An android device is connected to this computer in debug mode, do you want to install the generated APK onto it?"))) {
				Clock install_timer;
				if (!system_command(exe("adb"), {"install", "-f", output_path.toString()}, sout, serr)) throw Exception(format("Unable to install APK onto connected device, %s", serr));
				else if (!quiet) message(format("The application %s (%s) was installed on all connected devices in %ums.", config.getString("build.product_name"), config.getString("build.product_identifier"), uint32_t(install_timer.elapsed() / 1000)), "Success!");
			}
		}
	}
};
nvgt_compilation_output* nvgt_init_compilation(const string& input_file, bool auto_prepare) {
	nvgt_compilation_output* output;
	if (g_platform == "windows") output = new nvgt_compilation_output_windows(input_file);
	else if (g_platform == "mac") output = new nvgt_compilation_output_mac(input_file);
	else if (g_platform == "android") output = new nvgt_compilation_output_android(input_file);
	else output = new nvgt_compilation_output_impl(input_file);
	if (auto_prepare) output->prepare();
	return output;
}

#endif // !NVGT_STUB
