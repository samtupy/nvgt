# Subscripting tutorial
Subscripting is the concept of loading external Angelscript code into your game and executing it. This has many applications, including allowing you to make editional levels for your game that aren't directly included, and allowing your game admins to modify how certain items work. This tutorial contains a small example of the basic features of subscripting. We'll go over the ways to load code, find functions, and share methods between the nvgt scripts and your subscripts. For brevity, if I say nvgt code I am talking about the actual .nvgt scripts that are loaded by nvgt.exe and/or compiled. When I say the subscript, I'm talking about the code that the nvgt code is loading (E.G. a shared script in STW).

## Angelscript's Execution Flow
This section will talk just a bit about Angelscript's execution flow as it will help make these concepts a bit clearer. You won't specifically need to remember all of this, but it should give you a bit more of a framework for understanding what you do need to know.

The lowest level of executing an Angelscript is the engine, you don't need to worry about this (I create it in C++). NVGT only uses one Angelscript engine instance for all scripts, be that nvgt code or subscript code. The engine is where we register all of the c++ functions that nvgt can use, for example `key_pressed` or the string class. The only important note is that these functions are registered with different access masks (allowing you to control what functions subscript code have access to), we'll talk about that later.

The next step of code execution in Angelscript is to tell the engine to start what's known as a module for us. A module is basically a container for code. You feed the module code in as many sections (or files) as you want, then tell the module to build the code, making the module contain compiled bytecode now ready for execution. NVGT itself only uses one module called "nvgt_game", meaning that the "nvgt_game" module contains all the code contained in any .nvgt files that are included. Once the module of code has been compiled, the module is now aware of what functions, classes etc that the code contains. This means we can search for a function by name in a module, then call that function. When subscripting is involved, the nvgt code actually creates a second module at the request of the programmer (you'll see this below). Thus, the subscripting code runs in a different Angelscript module than the nvgt code does, and the most important point of this entire line is that the code in one angelscript module cannot immedietly access code in another module. If you start a new module for subscripting, the code in that module will not automatically have access to the variables or functions in the nvgt_game module, not unless you exclusively share each one.

## Sharing Code
There are 2 ways to share functions from the nvgt code to the subscript's code. Both have advantages and disadvantages, and unfortunately, neither are perfect. I'll be the first to admit that sharing functions with subscripts is actually the most annoying part of subscripting by far, though it is the type of thing where you set it up once and it's behind you sans any new functions you wish to share. The following are the considerations:

### Shared code
Angelscript does have this concept called shared code. If a module declares something as shared, other modules can easily access it using the "external" keyword in Angelscript. Lets create a small shared class for this example.
```
shared class person {
	string name;
	int age;

	person(string name, int age) {
		this.name = name;
		this.age = age;
	}
}
```

Now, so long as the top of our subscripting code contains the line
`external shared class person;`
We can successfully create and use instances of the person class in the subscripting code. So this all sounds great, what's the big problem with it? Oh how sad I was when I found out. Basically shared code cannot access non-shared code! Say that the person class shown above had a function in it that accessed a non-shared global variable in the nvgt code called score, the class will now fail to compile because the shared code of the person class cannot access the non-shared variable score. This is a horifying limitation in my opinion that makes the shared code feature much less intuitive to use. A slight saving grace is that at least non-shared code can call shared code E. non-shared code in the nvgt_game module can make instances of the person class just fine, but the person class (being shared code) can't access, for example, the non-shared list of person objects in your game that the person class wants to add instances of itself to. Luckily, there is a much better option in most cases.

### Imported functions
Angelscript shared modules provide the concept of importing a function from one module to another. Say you have a non-shared function in your game called `background_update`. If at the top of your subscripting code you include the line
`import void background_update() from "nvgt_game";`
and so long as you make one extra function call when building the module with subscripted code in it (`script_module.bind_all_imported_functions()`), the subscripting code can now successfully call the `void background_update()` function even though it is not shared in the nvgt code. The only disadvantage to this system is that it only works for functions! There is no such ability to say, import a class.

This all means that you will certainly need to combine these 2 methods of sharing code to share all of what you desire. For example you need to use the shared code feature to share a class interface with the subscripting code, but then since shared code can't access non-shared code, you need to use an imported function to actually retrieve an instance of that class (such as the player object) from the nvgt code.

## Full Example
Below you'll find a completely categorized example of how subscripting works, incapsilating all the concepts we've discussed thus far.

### Code to be shared with the subscripts
```
// A global array for person objects.
person@[] people; // Shared code doesn't work with global variables, so you can't share this.

shared class person {
	string name;
	int age;

	person(const string& in name, int age) {
		this.name = name;
		this.age = age;
	}
}

// Say we want the subscripting code to be able to create a new person.
person@ new_person(const string& in name, int age) {
	person p(name, age);
	people.insert_last(p);
	return p;
}

// Or in some cases, this is the closest you'll get to sharing a global variable, so long as it supports handles.
person@[]@ get_people() property { return @people; }
```

### Imports
Now lets create a section of code that imports the functions. This way, the user who writes subscripting code doesn't have to do it.

```
string imports = """import person@ new_person(const string& in, int) from "nvgt_game";
import person@[]@ get_people() property from "nvgt_game";
external shared class person;
""";
```

### Subscript code
```
string code = """void test() {
	person@ p = new_person("Sam", 21);
	new_person("reborn", -1);
	alert("test", people[0].name);
}

// This function needs arguments.
int64 add(int n1, int n2) {
	return n1 + n2; // normal int can be passed as argument but not yet for return values, consider it a beta bug.
}

// This function will be used to demonstrate how to catch script exceptions.
void throw_exception() {
	throw ("oh no!");
}
""";
```

### Calling the subscript
```
#include "nvgt_subsystems.nvgt" // To limit the subscript's access to certain nvgt core functions.

void main() {
	// Create a new module.
	script_module@ mod = script_get_module("example", 1); // The second argument can be 0 (only if exists), 1 (create if not exists), and 2 (always create).
	// Add the code sections, usually it's a section per file though they can come from anywhere.
	mod.add_section("imports", imports);
	mod.add_section("code", code);
	// Remember when I talked about an access mask earlier that allows you to limit what core engine functions can be called by the subscript? Now is the time to set that. If the function permissions aren't set at build time, there will be compilation errors and/or wider access than you intended. An access mask is just an integer that is used to store single bit flags as to whether the subscript should have access to a given set of functions. You can see the full list in nvgt_subsystems.nvgt. You can simply binary OR the ones you want to grant access to in this next call, all others will be disabled.
	mod.set_access_mask(NVGT_SUBSYSTEM_SCRIPTING_SANDBOX | NVGT_SUBSYSTEM_UI);
	// Now we need to build the module. We should collect any errors here which are returned in a string array. You should display them if the build function returns something less than 0.
	string[] err;
	if (mod.build(err) < 0) {
		alert("error", join(err, "\r\n\r\n"));
		exit();
	}
	// Next, if any functions are being shared via the imported functions method, we need to bind their addresses from this nvgt_game module to our example module. Don't worry it's just one line + error checking, but what is happening behind the scenes in this next call is that we are looping through all functions that have been imported, and we're searching for them by declaration in the nvgt_game module. When we find them, we tell the example module the function's address.
	if (mod.bind_all_imported_functions() < 0) {
		alert("error", "failed to bind any imported functions");
		exit();
	}
	// Cool, we're ready to go! Everything above this point you can consider an initialization step, code up to this point executes rarely, usually you'll want to store a handle to the script_module object somewhere and other parts of your code will repeatedly perform the steps below as calls are needed. Some wrapper functions that make calling common function types even easier are supplied later in this tutorial. We're about to start calling functions now. We can either retrieve a function by declaration, by index or by name.
	script_function@ func = mod.get_function_by_decl("void test()"); // This is useful because we can limit the returned function by return type and argument types, meaning that if 2 functions with the same name but different arguments exist, you will know you get the correct one.
	if (@func == null) {
		alert("error", "can't find function");
		exit();
	}
	// This looks a bit bulky, but it won't in actual usage when you don't need to show UI upon this error. Lets call the function!
	func({}); // Usually a dictionary of arguments is passed, this function takes none. Soon I think we'll be able to use funcdefs to call functions from shared code completely naturally, but we're not there yet and so now we use a dictionary, properly demonstrated in the next call.
	// Now lets demonstrate how to pass function arguments and how to fetch the return value. We'll skip the error check here we know the add function exists.
	@func = mod.get_function_by_name("add"); // Notice the lack of signature verification here.
	dictionary@ r = func.call({{1, people[0].age}, {2, people[1].age}}); // Notice how we can access those person objects created from the subscript.
	// The return value will be stored in a key called 0, and the other values will maintain the indexes that you passed to them encase the function has modified a value using an &out reference.
	int64 result = 1;
	r.get(0, result);
	alert("add test", result);
	// Usually it's good to check for errors when calling functions, unfortunately. In time this may be compressed so that a default error handler may exist or something of the sort, for now, this is possible.
	err.resize(0);
	@func = mod.get_function_by_name("throw_exception");
	func({}, err);
	if (err.size() > 0) alert("test", join(err, "\r\n"));
}
```

### Useful wrapper functions
Finally, I'll leave you with some useful functions that show how it's very easy to wrap the calling of common functions. As I said above later I plan to make it possible to call functions with funcdefs if I am able, but we're not yet there. For now, you can use a version of these. They will not run out of the box as they are copied from stw, but they should be all the example needed.

```
dictionary shared_function_cache; // It's useful to cache function lookups in a dictionary for performance, else Angelscript needs to keep looping through all shared functions to find the matching signature.

script_function@ find_shared_function(const string& in decl) {
	script_function@ ret = null;
	if (shared_function_cache.get(decl, @ret)) return @ret;
	@ret = script_mod_shared.get_function_by_decl(decl);
	shared_function_cache.set(decl, @ret);
	return @ret;
}

dictionary@ call_shared(const string& in decl, dictionary@ args = null, string[]@ errors = null) {
	script_function@ func = find_shared_function(decl);
	return call_shared(func, args, errors);
}

dictionary@ call_shared(script_function@ func, dictionary@ args = null, string[]@ errors = null) {
	if (@func != null) {
		bool internal_error_log = false;
		if (@errors == null) {
			internal_error_log=true;
			@errors = string[]();
		}
		@args = func.call(args, @errors);
		if (@errors != null and internal_error_log and errors.length() > 0)
			log_scripting("error", errors[0], errors.length()>1? errors[1] : "", errors.length()>2? errors[2] : "", "");
	}
	return args;
}

void call_shared_void(script_function@ func, dictionary@ args = null, string[]@ errors = null) {
	call_shared(func, args, errors);
}

bool call_shared_bool(script_function@ func, dictionary@ args = null, string[]@ errors = null, bool default_value = false) {
	@ args = call_shared(func, args, errors);
	if (@args != null) return dgetb(args, 0);
	return default_value;
}

double call_shared_number(script_function@ func, dictionary@ args = null, string[]@ errors = null, double default_value = 0.0) {
	@ args = call_shared(func, args, errors);
	if (@args != null) return dgetn(args, 0, default_value);
	return default_value;
}

string call_shared_string(script_function@ func, dictionary@ args = null, string[]@ errors = null, string default_value = "") {
	@ args = call_shared(func, args, errors);
	if (@args != null) return dgets(args, 0);
	return default_value;
}
```
