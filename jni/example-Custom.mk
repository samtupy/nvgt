# This project allows the creation of a Custom.mk file next to Android.mk with extra build setttings configured on a per-developer basis. Custom.mk is listed in NVGT's .gitignore file, so you can add values to it without risking committing it accidentally.
# It is done for convenience to make it easier to modify include or library paths without altering anything in version control or repeatedly specifying command line arguments to a build tool.
# Remember this file is an example, you must place any values you actually want to take effect in Custom.mk itself.

# the following will alter the path of NVGT's droidev folder in it's entirety, for example
LIBPATH := G:/droidev/lib
LOCAL_C_INCLUDES += G:/droidev/include
