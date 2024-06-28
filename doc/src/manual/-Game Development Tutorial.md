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

Let's make a calculator program with nvgt. We should be able to type mathematical expressions into it, and then get results out. We'll then build on our program by adding more features, and hopefully learn lots along the way!

You'll encounter many new programming concepts at once, so don't feel discouraged if you are lost. All will be explained!

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
[add more later here maybe]

Here is a full code example, which you can copy into an nvgt script and run.
```
#include "speech.nvgt"
void main(){
    speak("Hello from the NVGT speech include!");
}
```

### variables
If you know about variables in algebra, then you will have a similar concept in your head to those in programming. They are, at their core, names of data.

Quite a few things in nvgt are variables: functions, normal variables, classes and many more.

In this section we will learn about how to make some simple variables, and how to change them.
#### integers (ints) and unsigned integers (uints)
In NVGT, there are two main types of numbers, integers and floating-point numbers.

The easiest to understand is an integer, otherwise known as a discrete number. We'll learn about those first, then move on to floats, the type we will make the most use of in our calculator project.

Here are some examples of declaring the two kinds of integers:
```
int x = 3;
x = -3;
uint y = 3;
y=-3; // Oh no!
```
As you can see, we used both kinds of integers. One is called an int, as we'd expect, but the other is called a uint. What does the u mean? You might have already guessed!

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

The unsigned integer version of binary is actually easier to explain, so we'll start with that one.

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

#### float variables

The main difference between ints and floats is that floats can store fractional values, whereas ints are restricted to exclusively whole numbers. Although they do come with some drawbacks, this makes floats more suitable for tasks where a high level of precision is needed. They are also useful for dealing with imprecise, but extremely large, numbers.

There are two main types of floats in nvgt: float and double.

Float is a 32-bit (or single-precision) variable, and double is a 64-bit variant which can store a greater number of decimal digits and higher exponents.

In most cases, you should be okay to use a double, but this is not always required and is often not a good choice anyway.

The inner workings of floats are beyond the scope of this tutorial, but it's enough to know that computers don't think about fractional values like we do: the concept of decimal does not exist to them.

Instead, they use a binary representation, called the IEEE754 standard.

You cannot rely on floats storing a number perfectly. Sometimes, the IEEE754 standard has no exact representation for a number, and its closest equivalent must be used instead.

To demonstrate this, run this script. The result should be 1.21, but it isn't.
```
#include "speech.nvgt"
void main(){
    double result = 1.1 * 1.1;
    screen_reader_speak(result, false); // implicit cast from double to string
}
```
As you  can see, the value is very close, but not quite right. We even used the double type, with 64 bits of precision, but it wasn't enough.

There are several ways to get around this, but we don't need to worry about them for this project, so let's learn about another very useful type of variable: strings!

#### string variables
The easiest and most reliable way to think about string variables is that they are text. "hello" is a string, "this is a test" is a string, and "1" is a string (this last one is confusing but will be explained shortly).

We have actually seen string variables before. When we were making our hello world program, we used two of them for the title and text parameter to the alert function.

Now knowing about variables and their identifiers, you can probably see why we used quotes (") around them, and why that is necessary.

If we hadn't, "hello, world!" would've ended up being interpreted as two function parameters, the variable identifiers hello and world, neither of which existed in the program.

NVGT would not have liked this at all; in fact, it would've thrown numerous errors our  way in response.

So, quotes must enclose strings to let NVGT know that it should ignore the text inside - the computer doesn't need to know that it's text, only that it's data like text, which it can then show to the user for them to interpret.

It's almost, if not quite,  like delivering letters: you don't know or care about the information in a letter (and if you did, then your manager probably needs to talk to you!) but the letter's recipient does.

In the same way, NVGT will happily place text in quotes in strings, which can then be passed to functions, put into variables, or concatenated onto other variables or strings.

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
To give you some familiarity with string concatenation, let's go over a full example. Copy this into an NVGT script, and run it:
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

#### boolean variables (bool)
Leading up to a powerful idea called conditionals, boolean variables are another fundamental datatype in programming, and are usually present in some form in programming languages.

Named in honour of the mathematician and logician George Boole, the variables can store only two possible values: true or false - or 1 or 0, on or off, yes or no.

They are extremely powerful and there are quite a few things you can do with them, but most of them don't really make sense without conditionals. Still, we can give a basic example, using not (!), a logical operator:
```
void main(){
    bool state = true;
    speak("State is: " + state);
    state = !state;
    speak("Flipped, state is: " + state);
}
```
This shows how to declare a bool: it's fairly similar to other variables. Unlike strings, the values true or false do not need to be put in quotes, despite the fact that they are not variables in the traditional sense. These variables are actually consts, which means you can never accidentally overwrite their values; trying will yield an error.

That's all we'll learn about variables for now. We'll come back to them later on, but for our calculator project, this is all that we'll need to know.

#### Const Keyword
For this project, the last thing we will explore regarding variables is consts.

Const variables (or constants) are variables which can never change after they are first assigned. This must be done when they are initialized.

They are particularly useful in avoiding "magic numbers": using numbers directly in our code is bad!

Let's write some code to demonstrate:
```
#include "speech.nvgt"
void main(){
    speak("Welcome to the camping store! You need to have 30 dollars to buy a folding chair.");
}
```

This looks fine, but we're using this value in only one area of our code (mostly because there is only one place in which to use it, but that's beside the point).

Suppose, now, that we use the value 30 in many areas: not just telling the user how much it is to buy a chair, but also for the logic of buying and selling them itself.

This is also valid in that it works, but it is frowned upon.

Consider this: inflation is making everything more expensive these days, so what if we need to raise this price to 35 dollars next year?

The answer to that question is that it would be a coding nightmare! We would have to go through our code, painstakingly changing every reference of the value 30 to 35. But we could get it wrong: we might accidentally make one of the values 53, or change the number of centimeters in a foot from 30 to 35 in our frantic search - wouldn't it be much better if we only had to change the value once?

This is where consts will save the day!

Using them , we could rewrite our code like this:
```
const int price_foldable_chair = 30;
void main(){
    speak("Welcome to the camping store! You need to have " + price_folding_chair + " dollars to buy a folding chair.");
}
```
Much better! Now we can use this value wherever we want to, and all we have to do to change it is update the one declaration at the top of the file!

### conditionals and the if statement
The if statement is perhaps one of the most overwhelmingly useful pieces of code. Its ubiquity is almost unparalleled and a variation of it can be found in just about every programming language in use today.

Say you want to run some code, but only if a specific thing is true - the if statement is what you use. Let's give a full example:
```
#include "speech.nvgt"
void main(){
    int dice = random(1, 6);
    if(dice == 1)
        speak("Wow, you got " + dice + "! That's super lucky!");
    else if(dice < 4 )
        speak("You got " + dice + " - that's still pretty lucky, but aim for a 1 next time!");
    else
        speak("Ah, better luck next time. You got a " + dice + ".");
}
```
This small dice game is very simple. Roll a dice, and see how low a number you can get.

There are three options: you get a 1 (the luckiest roll), 2 or 3 (the 2nd luckiest), or 4-6 (which means you lose).

We can express these three options using the "if", "else if", and optional "else" constructions. They work like this:

if(conditional)

statement/block

else if(conditional)

statement/block

else if(conditional)

statement/block

else

statement/block

These are slightly different than normal statements, because they do not always have the ; where you would expect, at the end: if multiple lines are to be run (a block, surrounded by braces) then you use the ; on the last line of the block, before the }.

But what is a conditional?
A condition is any value that returns either true or false. This can be something which is already a bool variable, or the result of a comparison operator.
There are six comparison operators in nvgt, each of which takes two values and returns true or false based on their relationship.
| Operator | Purpose                                              | Opposite |
|----------|------------------------------------------------------|----------|
| ==       | Checks if two values are exactly equal               | !=       |
| !=       | Checks if two values are not exactly equal           | ==       |
| <=       | Checks if a value is less than or equal to another   | >        |
| >=       | Checks if a value is greater than or equal to another| <        |
| >        | Checks if a value is greater than another            | <=       |
| <        | Checks if a value is less than another               | >=       |

There are also four logical operators which work on bools, one of which we explored in the section on booleans. They are:
* && (and) returns true if the bools on the left and right are both true, but not neither or just one
* || (or) returns true if either or both of the bools on the left or right are true
* ^^ (xor) returns true only if one of the left and right bools is true, but not neither or both
* ! (not) returns the opposite of the bool on the right (it takes only one bool and nothing on the left)

Using these comparison operators and logical operators is how one creates conditionals to use in if statements, though remember that bools themselves can already be used directly.

This is all a lot of information at once, so here's a full example to demonstrate:
```
#include "speech.nvgt"
void main(){
    int your_level = 5;
    int monster_level=10;
    int your_xp=50;
    bool alive=true;
    if(alive)
        speak("You are alive!");
    if(monster_level<=your_level){
        speak("You manage to kill the monster!");
    }
    else{
        speak("The monster is higher level than you, so it kills you!");
        alive=false;
    }
    if(!alive)
        speak("You are no longer alive!");
    if(your_level*10==your_xp)
        speak("Your level is equal to a tenth of your experience points.");
}   
```
This example demonstrates an important distinction we touched upon earlier: if statements which use a block instead of a single statement need to have the block surrounded by braces.

Where a block might be used, a single statement can usually be used as well; the exception is functions, which must always use a block, whether or not it is a single line.

### loops
While the if statement is used to create conditional checks for whether certain pieces of code will be run, loops are used to repeat sections of code more than once.

Loops have many uses, including infinite loops (which are already a well-known concept), loops that run a known number of times, and loops that we use to run through certain data structures like arrays.

For advanced programmers, NVGT does not support iterators; the traditional c-style for loop must be used to iterate through arrays, although this is substantially more convenient because one can query their length.

NVGT has three main types  of loop, which we will discuss in this section: while loops, while-do loops, and for loops. We will also discuss the break and continue statements.

#### While Loops
The most simple form of loop is the while loop. It is written almost exactly the same as the if statement, and runs exactly the same, except that it will check the condition and run the code over and over, checking before each run, until the condition is determined to be false.

Here is an example which you can run:
```
#include "speech.nvgt"
void main(){
    int counter = 1;
    while(counter <6){
        speak(counter);
        wait(1000);
        counter+=1;
    }
}
```
This should speak out the numbers 1 through 5, with a second's delay between each.

Just like if statements (as well as other types of loops), a while loop can also be written with only one line of code inside. If so, it does not need to be surrounded by braces.

The while loop is the standard way to write an infinite loop: a piece of code that will run forever, perhaps until broken out of with the break keyword.

To make an infinite loop, we simply use
```
true
```
as the condition, since it will logically always return true, every time.

Here is a more complicated example (with a way to get out, this time, since we obviously don't want this to run forever - that would get boring really fast!):
```
// not complete yet
```
#### Do-While Loops
In while loops, the condition is checked before the code is run. This means that, just like an if statement, there is always the possibility that the code may never run at all.

On the other hand, in do-while loops, the condition is checked after the code has run. As a result, code will always run at least one time.

It's often up to the programmer which type they think is best, and there is no real standard. Whichever is more convenient and maps best to the situation can be used, and neither has a performance advantage over the other.

Let's rewrite our counter example using a do-while loop:
```
#include "speech.nvgt"
void main(){
    int counter = 1;
    do{
        speak(counter);
        wait(1000);
        counter+=1;
    } while(counter < 6);
}
```
As you can see, since the condition is at the end, we need to check it based on the value after the counter as updated, instead of before.

If we had used
```
while(counter < 5);
```
as we had done with our while loop, the code would have only counted to 4, since the counter gets updated after it speaks its current value.

### functions
Functions in nvgt are pieces of code that can be "called" or executed by other parts of the code. They take parameters (or arguments) as input, and output a value, called the "return value".

The return value is so named because it gives some critical piece of information back to the calling function, without which work cannot continue.

Let's use baking a cake as an example: in the process of baking a cake (simplifying greatly) you put the batter in the oven. The oven cooks the cake, and then you open it up and take a cooked cake out.

You can't do something else related to baking a cake while the oven is baking, because you don't have the cake: the oven does. In the same vein, only one function can be running at once, and we say that function is currently executing.

When a function ends, execution returns to the function from which it was called, just like taking the cake back out of the oven. It returns, along with execution, whatever is specified using a return statement (discussed shortly).
Here is a snippet for the purpose of example:
```
int add(const int&in a, const int&in b){
    return a + b;
}
```
Frankly, this code is a needless abstraction over an already-simple thing (the addition operator) and you should almost never do it like this in production. Nonetheless, it's a good example of what a function can do. It takes data in, and then outputs some other data.
The way we declare functions is a little bit strange, and this example is packed with new ideas, so let's break it down piece by piece:

int add(

The beginning of the function's declaration, letting the compiler know that it is a function with the return datatype (int), the name (add) and the left parenthesis

const

a guarantee to the compiler that this variable will not be re-assigned

int

the type of the first variable

&in

Denotes a reference, specifically an input-only (or read-only) reference. Since the compiler knows we won't change the data (we used const), this reference can improve performance, because the value doesn't need to be copied for our function.


a, 

the name (identifier) of the first parameter/argument variable, and a comma and space to separate it from the next variable, just as we use when calling functions

const int&in b)

The declaration of the second parameter/argument variable, a read-only integer reference, and a right parenthesis to tell the compiler there are no more parameter variables

{

The beginning of our function (remember, there must always be braces enclosing functions, even if the execution step is only one line in length.)

Then, the next line:

    return a + b;

This is the only line in our function, and returns an expression evaluating to an int variable. It adds the a and b variables' values together.

}

The end of our function, which lets the compiler know that we're back in the outer scope (probably global)

* arrays/lists
* classes (methods and properties)
* datastreams and files