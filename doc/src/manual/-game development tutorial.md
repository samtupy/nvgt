# Effective Programming and Game Development with NVGT
## What is Game Development?
If you are an experienced programmer looking to get skilled up with NVGT as fast as possible, you can safely skip this section.
To someone who has never programmed before, the development of games might seem like an insurmountable task. This manual hopes to help with the steep learning curve of programming, and to get you ready to make the games of your dreams all on your own.
There are many things that need to be considered carefully in the development of a game. One of the most curious is programming; very quickly, programming stops aligning with real-world concepts. The precise instructions and rigid syntactic rules are often the bane of a new programmer's existence. As you learn more, you begin to "speak" programming more intuitively. You will eventually realize that programming languages are nothing more than a readable abstraction over common paradigms: variables, functions, conditions, loops, data structures, and many more. Start thinking of programming as a new way to think and construct new ideas, rather than a way of expressing already-imagined thoughts and ideas. And if you don't understand these paradigms yet, don't worry - reading this manual, my hope is that you will learn to make games with nvgt, but I have a secondary goal: by the end of this text, I hope that you will also be confident with programming in general, as well!
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
In this chapter, we'll learn about many of the fundamental concepts of nvgt, and of programming as well!
Before we take a look at what our finished program will look like, I will first explain the nvgt and programming concepts we'll need to understand it, using some short examples. They are called snippets, and won't all actually run. They are just to demonstrate.
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
### variables
If you know about variables in algebra, then you will have a similar concept in your head to those in programming. They are, at their core, names of data. Quite a few things in nvgt are variables: functions, normal variables, classes and many more.
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
#### bonus: binary 1100101 (or 101)
To understand signed and unsigned integers (and to understand integers) we must first understand binary. Otherwise known as base 2, it is a system based on 0s and 1s. It's most well known for appearing on terminals in poorly written movies about hackers, but it is integral to understand it as a programmer, so let's talk about it.
The unsigned integer version of binary is actually easier to explain, so we'll start with that one. In terms of byte order, we will assume big-endian, but you don't need to worry about that because this is probably what you will be dealing with. Little-endian is just big-endian in reverse, which as you will soon discover is fairly easy to visualize.
Consider a row of bits. In base 2, we can already surmise that the maximum possible value is 2^bits-1. NVGT's ints are 32-bit, although it does also support int64 and uint64 types if you want them.
The unsigned integer (uint) type in nvgt, thus, can store a maximum value of 4.294 billion. This is a huge number, and is suitable for most, if not all, requirements. The unsigned 64-bit integer type can store a value of up to 18.446 quintillion, which is more than two billion times the world population and more than a thousand times the amount of money in circulation in the entire economy, in US cents.
The first bit on the left is worth 2 raised to the n-1th power, where n is the number of bits.
If the bit is set to 0, it means no value is added to the total in base 10. If it's set to 1, you add its worth.
From left to right, each bit is worth half the bit before it. Let's give examples with 8 bits, since that's much easier to think about than 32 bits.
consider this set of bits: 01100101
The leftmost bit in this group would be worth 128, since that's the value of 2^(8-1).
but it's set to 0, so we don't do anything
right another bit, and we get a bit of worth 64, set to 1. So, we add 64.
Next, another 1 bit, with a value of 32, which we add, giving us 96.
Next, two 0 bits, each worth 16 and 8. We will ignore them.
Another 1 bit, worth 4. Let's add it, for a total of 100.
Then, a 0 bit, worth 2, and another 1 bit, worth 1. Adding the last 1 bit, we have our final total, 101.
### conditionals
not written
### loops
not written
### functions
Functions in nvgt are pieces of code that can be "called" or executed by other parts of the code. They take parameters (or arguments) as input, and output a value, called the "return value".
The return value is so named because it gives some critical piece of information back to the calling function, without which work cannot continue.
!Let's use baking a cake as an example: in the process of baking a cake (simplifying greatly) you put the batter in the oven. The oven cooks the cake, and then you open it up and take a cooked cake out. You can't do something else related to baking a cake while the oven is baking, because you don't have the cake: the oven does. In the same vein, only one function can be running at once, and we say that function is currently executing.
When a function ends, execution returns to the function from which it was called, just like taking the cake back out of the oven. It returns, along with execution, whatever is specified using a return statement (discussed shortly).
* arrays/lists
* classes (methods and properties)
* datastreams and files
