# Effective Programming and Game Development with NVGT
## What is Game Development?
If you are an experienced programmer looking to get skilled up with NVGT as fast as possible, you can safely skip this section.

To someone who has never programmed before, the development of games might seem like an insurmountable task. This manual hopes to help with the steep learning curve of programming, and to get you ready to make the games of your dreams all on your own.

There are many things that need to be considered carefully in the development of a game. One of the most curious is programming; very quickly, programming stops aligning with real-world concepts. The precise instructions and rigid syntactic rules are often the bane of a new programmer's existence.

As you learn, you will begin to "speak" programming more intuitively. You will eventually realize that programming languages are nothing more than a readable abstraction over common paradigms: variables, functions, conditions, loops, data structures, and many more. Start thinking of programming as a new way to think and construct new ideas, rather than a way of expressing already-imagined thoughts and ideas.

And if you don't understand these paradigms yet, don't worry - reading this manual, my hope is that you will learn to make games with nvgt, but I have a secondary goal: by the end of this text, I hope that you will also be confident with programming in general, as well!

Especially in the world of audiogames, whose developers are often small teams at most, skill in game design is correlated with skill in programming; this manual will attempt to teach you both. However, game designing itself can also be made into a career!

When making games, you must first consider what your game will be: what are the rules of the game? What is the lore, if it has a story? Plan out your project in detail, so that it's easier to turn it into code later on. This is especially true of projects that have a plot, or at least backstory.

As well as coding and designing the game, sounds must also be found or created; many high-quality resources can be found for this, be they free or paid.

It is also the case that a released game is not necessarily a finished one: multiplayer games need administration to keep them running, and games might need to be maintained or updated to fix bugs that you did not encounter until post-launch.
## Your First NVGT Script
A script can also be considered one "unit" of code. You have probably seen many of these before: .py, .js, .vbs, perhaps .bgt, and now .nvgt. A script can be executed, meaning that the code contained within will be run by nvgt.

Usually, one game will consist of not just one, but many scripts, each of which has some specific function or purpose. For now, though, a single script will be sufficient for our needs.

A common tradition among programmers is to write a program that outputs "hello, world!" to the screen, to make sure whichever language they're using is working properly.

Let's do that now and say hello to NVGT!
Open a file in your text editor of choice (I recommend notepad++) and paste the following code inside:
```
void main(){
    alert("hello", "Hello, world!");
}
```
Now, save this file as hello.nvgt, and head over to it in your file explorer.

Press enter on it, and you should see a dialog box appear, with our message inside!

Congratulations - you've just written your first nvgt script!

This script might look simple, but there's actually quite a bit going on here. Let's analyze our various lines:

void main(){ - this is the beginning of a function (more on those later) which doesn't return anything, and takes no arguments, or parameters.

The { afterwards opens a code block. It's customary in many codebases to put the { on the line which opens the block, and to put the closing brace on a new blank line after the block ends.

Inside our block, we have one line: alert("hello", "Hello, world!");

Let's break it down:

alert() is a function in nvgt that opens a dialog box containing a message. It supports many arguments, but most are optional. Here, we have used the two that are not: title, and text.

We've separated our parameters by a comma and a space, similar to what we do when listing items in English, although we don't need to use "and" like we do in English, and there is only one rule to remember: a comma after every item, except the last.

Our parameters are enclosed in parentheses () but why? This tells NVGT what we'd like to do with the alert function: we would like to call it (calling meaning running the code inside based on some values). Finally, we end the line with a semicolon ; that tells NVGT this piece of code is finished.

Together, alert("hello", "Hello, world!"); is known as one statement, the smallest unit of code that can be executed.
As you can see, functions aren't so daunting after all!

However, there's one missing piece of this puzzle: what's the deal with the main() function?

Actually, it's arbitrary, although extremely common. Many programming languages (rust, c, c++, java, and NVGT, to name a few) require you to use the main() function as what's called the "entry point": in other words, NVGT will call the main function, just as we called the alert function. If it doesn't find the main function, it won't know where to start, and will simply give you an error stating as much.

It's very possible to write scripts without a main function. These are sometimes called modules, and sometimes called include scripts, helper scripts, or any number of other names. In NVGT, since a module is quite a different (and advanced) concept, we call them include scripts.

There's something interesting which nvgt can do with this script: not only can you run it, but you can also pack it into an exe file, ready to be shared with whoever you wish to have it. The advantage is that the exe will obfuscate your code and protect it from bad actors, which is especially useful for multiplayer projects!

Not just that, but anyone can run your game if you compile it, whether or not they have nvgt installed on their computers.

It's easy to do: when you've selected your script in windows explorer, don't run it. Instead, press the applications key (alternatively shift+f10 if you don't have one of those) and a "compile script (release)" option should appear.

Click it, and a new file should appear next to the script: hello.exe.

Running this file, you should get a similar effect to just running the script, but the code is now protected and can no longer be accessed.

Now that we've learned the basics of nvgt scripts, let's move on and create a simple program!
## Learning Project: Calculator

Let's make a calculator program with nvgt. We should be able to type mathematical expressions into it, and then get results out. We'll then build on our program by adding more features, and hopefully learn lots along the way! You'll encounter many new programming concepts at once, so don't feel discouraged if you are lost. All will be explained!

In this chapter, we'll learn about many of the fundamental concepts of nvgt, and of programming as well! I will try to make this interesting, but learning the basics can admittedly be boring. It is not shameful if you need a coffee or two reading through this.

And once we've learned the basics, we'll create several versions of our project, each one better than the last!

I will first explain the nvgt and programming concepts we'll need to understand it, using some short examples. They are called snippets, and won't all actually run. They are just to demonstrate.
### comments
Sometimes, you might want to document what a particularly complex bit of code does, or perhaps remind yourself to make it better later.

For these reasons and more, programming languages usually have some way of keeping some notes in your code that they will not attempt to execute.

These are usually called comments, and nvgt has three types of them:

The single-line comment is written with a //, and looks like this:
```
// Hello!
```
The multi-line comment is written slightly differently, enclosed by a /* and a */. It looks like this.
```
/*
Hello!
This is a multiline comment
Lorem ipsum
Dolor sit amet
*/
```
Lastly, the end-of-line comment is sort of like a single-line comment, but goes after a line of code. For example:
```
int drink_price=5; // should this be able to store fractional values?
```

As well as documenting your code, comments (especially multi-line ones) can be used to surround code which temporarily doesn't need to be run, or is broken for some reason.

This is called "commenting out" code. Code which is commented out will be ignored by the compiler, just like regular textual comments.

Example:
```
void main(){
//alert("hello", "hello, world!")
alert("how are you", "My name is NVGT!");
}
```
If you run this, you will only see the "how are you" dialog box, and not our "hello" one. You see, I made a little error when I was writing that line - can you spot why we might have commented it out?

### include scripts
The truth about programming, as with anything, is that organization is the most important thing. Always remember this: reading code is more difficult than writing it.

As a programmer, your highest-priority task is to get the code working. But arguably just as important is to keep it working.

Imagine you are a version of yourself, with similar programming experience. However, you have never read your project's code before. If you can intuitively understand what all of its components do, then you have succeeded in writing readable code!

Another thing experienced programmers like to have is modularity. This philosophy dictates that as little of your code as possible should depend on other code.

I'll explain more about this later, but an include script is how one achieves modularity in nvgt: by using the #include directive at the top of your program, you can load in another file of code, adding its code to your own in doing so.

NVGT ships with a host of include scripts (or includes for short), which you are free to use to speed up the process of game development.

For example, the speech.nvgt include has functions for making your game speak out text, without needing to worry about what screen reader or sapi voice the user has.

If you wanted to use the speech.nvgt include, you would put it at the very top of your script, like this:
```
#include "speech.nvgt"
```

Why the #? In nvgt, # signifies what's called a preprocessor directive: usually one line of code, these are used before your program is run to change something about it.

NVGT has what's called an include path. It searches multiple folders for your include scripts, and if it can't find them, it will give you an error. It works a bit like this:
1. Search the directory of the script from which another script was included
2. Search the include folder in nvgt, in which all the built-in includes are stored.
//add more later here maybe

Here is a full code example, which you can copy into an nvgt script and run.
```
#include "speech.nvgt"
void main(){
    speak("Hello from the NVGTT speech include!');
}
```

### variables
If you know about variables in algebra, then you will have a similar concept in your head to those in programming. They are, at their core, names of data.

Quite a few things in nvgt are variables: functions, normal variables, classes and many more.

In this section we will learn about how to make some simple variables, and how to change them.
#### integers (ints) and unsigned integers (uints)
In NVGT, there are two main types of numbers, integers and floating-point numbers.

The easiest to understand is an integer, otherwise known as a discrete number. Here are some examples of declaring the two kinds of integers:
```
int x = 3;
x = -3;
uint y = 3;
y=-3; // Oh no!
```
As you can see, there are two types of them. One is called an int, as we'd expect, but the other is called a uint. What does the u mean? You might have already guessed!

We'll talk about that in a second. And if you don't want to learn about binary now, it's enough to know that unsigned ints sacrifice the ability to store negative values for double+1 the positive number range.

First, let's break down our int declaration statement

`int` is the type of variable (int)

`x` and `y` are the "identifier" of a variable. In other words, its name.

`=` is the assignment operator. The first time you assign a value to a variable, it is called initialization.

After the =, a value is assigned to the variable. Then, the ; is used to end our statement, making it complete and ending the line.

You'll notice that only the first reference of a variable needs its type; this is because this is the declaration of the variable, whereas the second line is a reassignment of the same variable and does not need to be re-declared.

You can also declare what are called global variables. I'll give a full example to demonstrate this.
```
int unread_emails = 20;
void main(){
    alert("important", "You have " +unread_emails + " unread emails!");
}
```
As you can see, despite the fact that the global variable was not declared within the function (or its scope), we can still use it. This is because it's not declared in any function, and can thus be used from all functions in your program.

This author personally does not recommend much usage of globals. A more elegant way to use variables in lots of different functions at once will be demonstrated shortly. The exception is consts, which will also be discussed later.

To create the message, I used the string concatenation operator to glue one string, one variable, and another string together. This will be further explained in the section on Strings.

As we know, inside a function (but not outside) variables can be changed, or re-assigned. You might have realized that changing a variable's value in relation to itself (like giving the player some money or points) is a handy side effect, since you can simply reference a variable when re-assigning it, like this:
```
int level = 2;
level = level + 1;
```
But there is a simpler, more readable way of doing this, which saves lots of time (and cuts down on typos!). 

If you want to change a variable in relation to itself like this, you use what's called compound assignment.

This combines an operator, like an arithmetic operation or string concatenation, with the assignment operator.

For example, we could rewrite our previous code using compound assignment:
```
int level = 2;
level +=1;
```
As you can see, it's much cleaner!

Here's a full example to consolidate what we've learned. You can copy and paste it into an nvgt script and run it. We'll also demonstrate includes and comments again!
```
#include "speech.nvgt"
int g = 3; // a global variable
void main(){
    /*
    This program demonstrates integers in NVGT, by declaring one (a) and performing a variety of arithmetic operations.
    After each operation, the value of a will be spoken.
    */
    int a = 0; // This is the variable we'll use. 
    speak("a is now " + a);
    a+=2;
    speak("After adding 2, a is now " + a);
    a*=6;
    speak("After multiplying by 6, a is now " + a);
    a /=3;
    speak("After dividing by 3, a is now " + a);
    //something new!
    a -= g;
    speak("After subtracting g, a is now " + a);
}
```

#### bonus: binary 1100101 (or 101)
To understand signed and unsigned integers (and to understand integers) we must first understand binary. Otherwise known as base 2, it is a system based on 0s and 1s. It's most well known for appearing on terminals in poorly written movies about hackers, but it is integral to understand it as a programmer, so let's talk about it.

The unsigned integer version of binary is actually easier to explain, so we'll start with that one. In terms of byte order, we will assume big-endian, but you don't need to worry about that because this is probably what you will be dealing with. Little-endian is just big-endian in reverse, which as you will soon discover is fairly easy to visualize.

Consider a row of bits. In base 2, we can already surmise that the maximum possible value is 2^bits-1. NVGT's ints are 32-bit, although it does also support int64 and uint64 types if you want them.

The unsigned integer (uint) type in nvgt, thus, can store a maximum value of 4.294 billion. This is a huge number, and is suitable for most, if not all, requirements. The unsigned 64-bit integer type can store a value of up to 18.446 quintillion, which is more than two billion times the world population and more than a thousand times the amount of money in circulation in the entire economy, in US cents.

The first bit on the left is worth 2 raised to the n-1th power, where n is the number of bits.

If the bit is set to 0, it means no value is added to the total in base 10. If it's set to 1, you add its worth.

From left to right, each bit is worth half the bit before it. Let's give examples with 8 bits, since that's much easier to think about than 32 bits.

Consider this set of bits: 01100101

The leftmost bit in this group would be worth 128, since that's the value of 2^(8-1).

But it's set to 0, so we don't do anything

Right another bit, and we get a bit of worth 64, set to 1. So, we add 64.

Next, another 1 bit, with a value of 32, which we add, giving us 96.

Next, two 0 bits, each worth 16 and 8. We will ignore them.

Another 1 bit, worth 4. Let's add it, for a total of 100.

Then, a 0 bit, worth 2, and another 1 bit, worth 1. Adding the last 1 bit, we have our final total, 101.

This is all you need to know about unsigned binary representation.
#### string variables
The easiest and most reliable way to think about string variables is that they are text. "hello" is a string, "this is a test" is a string, and "1" is a string (this is confusing but you'll soon know what I mean).

We have actually seen string variables before. When we were making our hello world program, we used two of them for the title and text parameter to the alert function.

Now knowing about variables and their identifiers, you can probably see why we used quotes (") around them, and why that is necessary.

If we hadn't, "hello, world!" would've ended up being interpreted as two function parameters, the variable identifiers hello and world, neither of which existed in the program.

NVGT would not have liked this at all; in fact, it would've thrown numerous errors our  way in response.

So, quotes must enclose strings to let NVGT know that it should ignore the text inside - the computer doesn't need to know that it's text, only that it's data like text, which it can then show to the user for them to interpret. It's almost, if not quite,  like delivering letters: you don't know or care about the information in a letter (and if you did, then your manager probably needs to talk to you!) but the letter's recipient does. In the same way, NVGT will happily place text in quotes in strings, which can then be passed to functions, put into variables, or concatenated onto other variables or strings.

In this case, it was assigning them to the title and text variables, arguments of the alert function.

String variables are created using a similar syntax to the int variable we just saw:
```
string name = "Rory";
```
You can also create a string with multiple words:
```
string message = "How are you today?";
```
Or even a string with non-ascii characters:
```
string message2 = "Hello, and 你好 👋";
```
Just like integer variables, strings also have operations which can be performed on them. By far, the most common is concatenation.

Concatenation is the process of stringing strings together. The + symbol is used for this, and compound assignment with += is also supported.

Let's see how it works:
```
string sentence = "The quick brown fox";
message += " jumps over the lazy dog";
```
To give you some familiarity with string concatenation, let's go over a fulle example. Copy this into an NVGT script, and run it:
```
#include "speech.nvgt"
void main(){
    int a = 1;
    int b = 2;
    string c = "1";
    int d = 2;
    string result1 = a + b;
    string result2 = c + d;
    speak("a + b is " + result1);
    speak("c + d is " + result2);
}
```
The output should be:

a + b is 3

c + d is 12

Is that what you expected?

What's happening here is called casting, specifically implicit or automatic casting. In programming, casting means converting some value of one type (int) to another type (string).

When we calculate result1, we perform addition on a + b (1 + 2) and get 3, which makes sense.

But when we calculate result2, NVGT automatically converts d, an int, into a string, making it "2", so it can be concatenated.

It then ignores the data inside, and just adds it together. So, instead of having 1 + 2, you get "1" + "2" - which is just two pieces of data combined together into one string, making "12".

This is why strings are so useful: they can hold any data in a text-like form, and then the meaning of that data can be interpreted by something else. In this case, it is output to our screen readers, and we can interpret it; the sound waves by themselves do not hold any semantic information.

### conditionals
not written
### loops
not written
### functions
Functions in nvgt are pieces of code that can be "called" or executed by other parts of the code. They take parameters (or arguments) as input, and output a value, called the "return value".

The return value is so named because it gives some critical piece of information back to the calling function, without which work cannot continue.

Let's use baking a cake as an example: in the process of baking a cake (simplifying greatly) you put the batter in the oven. The oven cooks the cake, and then you open it up and take a cooked cake out.

You can't do something else related to baking a cake while the oven is baking, because you don't have the cake: the oven does. In the same vein, only one function can be running at oncea, and we say that function is currently executing.

When a function ends, execution returns to the function from which it was called, just like taking the cake back out of the oven. It returns, along with execution, whatever is specified using a return statement (discussed shortly).
* arrays/lists
* classes (methods and properties)
* datastreams and files