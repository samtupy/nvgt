# Concurrency Tutorial

## Introduction to multithreading and parallelism in NVGT

Multithreading, often referred to as concurrency, is the process by which a program can divide tasks into separate, independent flows of execution. These tasks, known as threads, can run concurrently within a single process, allowing for more efficient use of resources and faster execution of complex programs. This approach differs from parallelism, where the tasks are executed simultaneously on multiple processors or computers.

Concurrency focuses on the structure and design of the program to handle multiple tasks that can overlap in execution. This is particularly useful in scenarios where tasks can be interleaved and do not need to run at exactly the same time, such as managing user interfaces, I/O operations, or handling multiple client requests in a server.

In contrast, parallelism aims to improve computational speed by executing multiple tasks simultaneously. This can be achieved through multi-core processors, where each core can execute a separate thread, or distributed systems, where tasks are distributed across different machines in a network.

While NVGT does not support parallelism as one might use it in other programming languages, it does support threads, and this article is all about that. The above distinctions are important, however, because they are quite different, and the way one would go about implementing parallelism is vastly different (and more complicated) than how one would implement concurrency. We denote the distinction explicitly here because often these terms are used interchangeably when they do, in fact, mean very different things, although on a single computer they can appear to be very similar. We will not be discussing parallelism any further in this article, however, as concurrency is the more important aspect here.

## Why is this so important?

By far, the easiest way to program is by sticking to synchronous execution, which is what happens by default unless any concurrency is specifically introduced by the programmer. Synchronous execution means that each statement in your code runs to completion before the next is executed. However as your game grows, you may find that it begins to execute slowly, which may temmpt you to quickly implement concurrency into your application.

This however poses a significant issue because NVGT supports three types of concurrency, and not knowing what method to use or when to use it can often result in slower or more buggy code than if either a different method of concurrency had been used, or if concurrency had not been used at all. People most often jump strait to threads to solve a problem of performance, when, 99 percent of the time, the performance degradation comes from an easily solvable issue in the person's code and not NVGT or a true need for threads or the lowest levels of concurrency. It can be not only bad practice but also detrimental to your program's development to use more advanced concurrency methods when a simple loop would have sufficed, but knowing when and how to spin up a thread when synchronous execution just won't cut it can also save the day in such cases. As such, this article attempts to explain:

* What exactly concurrency is;
* How to use concurrency correctly; and
* The golden rules of concurrency.

The above explainers are important because concurrency is easy to use improperly. Users of it who don't understand it are bound to make critical mistakes that can cause any number of things, such as:

* Sequential execution, i.e., absolutely no actual gain and a waste of resources
* Data races
* Deadlocks
* And worse

They'll also notice their code suffering very strange bugs or exhibiting very odd behaviors, all of which is very, very difficult to debug, let alone track down in the first place, especially on larger projects, and it's best that you be aware of these issues before ever considering threads.

## Three types of concurrency?

There are three types of concurrency that NVGT supports: async, coroutines, and threads. We'll discuss all of them in this article.

### Note

Any plugins you load may add even more methods of concurrency or even parallelism. Though this article will help you use those extra methods correctly, you should always read the documentation of those plugins to get a firm grasp of how their extra methods work.

## Async

Async is the first type of concurrency, and one of the easiest to use. It's also one of the simplest to understand. Although async (may) use a thread (or even multiple) under the hood, it is entirely possible that it may not, and you, as the programmer, needn't care how it works as long as your able to do what needs to be done. In the majority of cases, this is probably the furthest you will ever need concurrency in your game.

Unlike the other two forms of concurrency, the engine insulates you (mostly) from the problems and mistakes of concurrency that you may make. This is particularly true for functions like `url_get` and `url_post` where the engine can complete the request while you do other things, or in any case that involves writing an asyncronous function that does not share any state with the rest of your program. Take, for example, this code:

```nvgt
async<string> result(url_get, "https://nvgt.gg");
```

This class is known as a templated class. Though it is beyond the scope of this article, the `string` part is the most important, besides the arguments of the constructor, which specify both the function to be executed and it's arguments. When you create (or instantiate) a class that's templated, NVGT generates the code for that specific class automatically for you, using the types you specify in the angle brackets. This is done on the fly and doesn't harm performance in any manner.

You may not realize it, but this constructor can take up to 16 parameters. (Woohoo, that's a lot!) When the constructor completes, `result` has some things of interest:

* The `value` property, which is (in this case) of type `string`, and contains the return result of the function invoked. If you change `string` above to, say, `int`, then this will be of type `int`, not `string`.
* A `complete` and `failed` property, which tells you if the task has finished executing, or failed in some manner, respectively.
* An `exception` property which provides you any information that you need if, during the execution of the function, it failed and threw one.
* A `wait()` method which pauses, or blocks, your code from continuing until the function completes or fails.
* a `try_wait` function, returning type `bool`, which takes a timeout and will block until either the timeout( also known as the deadline) expires or the task completes.

As stated previously, this is, for the majority of cases, the only thing you will need to reach for in your toolbox, and it's the highest level of concurrency available. The next two are much lower level, and give you more control, at the cost of raising the steaks by quite a bit. Even then, we strongly recommend reading the sections below about what can go wrong when 2 bits of code running at the same time try accessing the same global variable or bit of memory if you intend to write your own functions that are to be called with this async construct.

## Coroutines

A coroutine is a function that suspends itself at certain points. This suspension is called yielding, and using coroutines is known as cooperative multitasking.

In computer architecture and operating systems, there are generally two types of multitasking approaches. Multitasking, for those who are unsure of the definition (and no, we don't mean multitasking in normal human language), is the concurrent execution or handling of multiple computational processes by a CPU or other processing units within a computer system, such that multiple tasks are performed during overlapping time periods. The key definition is "overlapping time periods." The two types that are generally accepted are known as cooperative multitasking and preemptive multitasking.

Cooperative multitasking is the first type and works by requiring that a task executes until it reaches a point where it can allow another task to run; this is known as a yield point. When the task reaches this point, it makes a call to a function provided by the operating system, runtime environment, or whatever is running each task, telling it that it is ready to step aside and allow something else to run. In NVGT, this is done through the `yield()` function. Cooperative multitasking relies on each task being well-behaved and voluntarily yielding control, ensuring that all tasks get a chance to execute. This approach is simpler and can be more efficient in environments where tasks can be trusted to yield regularly. However, if a task fails to yield, it can cause the entire system to become unresponsive.

Preemptive multitasking, on the other hand, is used in all well-known operating systems. Preemptive multitasking works by allocating a task a certain amount of time to run, known as a time slice, and allowing it to run until that time slice ends. When the time slice has elapsed, the operating system forcefully suspends (or "preempts") the execution of the task and replaces it with another task, and the cycle repeats forever. Usually, time slices are very short (perhaps only a few microseconds) and so this gives the illusion that the computer is able to do many things simultaneously. In multicore and multiprocessor systems, this is actually true: the computer can and does do many things all at the same time since the multitasking can occur on all the processors at the same time. However, all that's really happening is that the system is constantly performing this song and dance on all the processors in your computer, all at the same time!

You may have noticed that we used the word "task" instead of "process" or "thread." This is because, in a computer, there are a few different types of "tasks," and they're all the same to the computer:

* Process: A fully loaded program that runs. It has code, data, assets, etc.
* Thread: A task within a process. It shares the code and data of its parent program and is able to access all the state within. More on this later.

So, how does this have anything to do with coroutines? Well, when you create a coroutine, you are engaging in cooperative multitasking. The coroutine will begin execution as soon as you call `create_coroutine` and will pause the execution of all your other code until you call `yield()`. So, you must remember to yield at some point! The best places to do this are in loops or when your function is about to do something that could take a while, for example, some network-based IO. If you don't, none of your other code can run!

However, the same applies to the rest of your code: it, too, must yield; otherwise, your coroutine will never be able to proceed!

Unlike threading, which involves preemptive multitasking, it is (theoretically) impossible for a coroutine that executes in this manner to cause data races or other concurrency problems. This is because only one flow of execution is allowed at any given moment. You can definitely make it appear that multiple things are happening at once if you yield enough, but you'll never be able to duplicate the kind of problems that threading has, so you usually don't need to worry about those. This does not, however, mean that coroutines are the go-to option for all scenarios.

Coroutines are particularly useful for scenarios where tasks need to perform lengthy operations without blocking the entire program. For instance, they are excellent for handling asynchronous I/O operations, long-running computations that need to provide intermediate results, and any situation where tasks need to cooperate smoothly without complex synchronization mechanisms.

There are some rules to remember when using coroutines, however:

* Ensure that your coroutines yield control back to the caller at appropriate points, particularly in loops or before performing lengthy operations.
* Do not perform blocking operations (like waiting for I/O) within a coroutine without yielding. Instead, yield control and resume the coroutine once the operation completes. The `async<T>` class can help with this: you can store it in a variable your code has access to, and when it completes, you can `yield` to allow one of your coroutines to continue.
* Always clean up resources before yielding or ensure that resources are properly managed upon resumption. This helps prevent resource leaks and ensures that the coroutine does not hold onto resources unnecessarily.
* Design your coroutines to work well with others.
* Thoroughly test your coroutines, particularly their yield and resume behavior. Debugging coroutines can be challenging due to their non-linear execution flow, so use logging and debugging tools to track their state and behavior.

To create a coroutine, call the `create_coroutine` function:

```nvgt
void create_coroutine(coroutine @func, dictionary @args);
```

Your coroutine should take the form:

```nvgt
void coroutine(dictionary@);
```

In both of these, `dictionary@` is a dictionary of arguments that the coroutine needs to execute. When your ready to yield, simply call `yield`:

```nvgt
void yield();
```

As an example, let's say we wanted to calculate the factors of an integer. Although this is fast for small numbers, it can very quickly become quite computationally expensive when the numbers are particularly large. We might define the coroutine as:

```nvgt
void generate_factors(dictionary@ args) {
    const uint64 number = uint64(args["n"]);
    uint64[] factors = {1, number}; // Initialize factors with 1 and the number itself.

    for (uint64 i = 2; i * i <= number; ++i) {
        if (number % i == 0) {
            factors.insert_last(i);
            if (i * i != number) {
                factors.insert_last(number / i);
            }
        }
        yield(); // Yield control after each iteration
    }

    factors.sort_ascending();

    for (uint64 i = 0; i < factors.length(); ++i) {
        println("%0".format(factors[i]));
        yield(); // Yield control after printing each factor
    }
}
```

Then, before we start our game loop:

```nvgt
dictionary args;
args["n"] = 100000;
create_coroutine(@generate_factors, @args);
```

Now, in our game loop, we need somewhere to yield:

```
while (true) {
    wait(1);
    yield();
    ...
}
```

## Threads

### STOP!

Before you consider using threads, understand that they are the most complex and error-prone way to handle concurrency. Threads share state with your entire program, meaning they can easily cause data races and deadlocks if not managed correctly. These issues can make your game crash, behave unpredictably, or become very difficult to debug. Unless you have a specific, compelling reason to use threads, stick to `async` (or coroutines if you really need them).

### Note

This section is extremely technical in places. This is because multi-threading can be difficult. Even after doing it for a few years you will begin to learn that there are subtle mistakes you can make without realizing it. After we get through the different methods of protecting your code, we'll get into how to use threads and the rules on using them properly. If you want to know how to use any of the synchronization primitives discussed here, the documentation is your friend, as well as the NVGT community.

### Introduction

A thread is much different than a coroutine. A thread runs alongside your code, and could even run on other processors in the system. A thread introduces many other problems that coroutines don't: they share state with the rest of your game, meaning they have access to all the global variables the rest of your code does.

One of the most critical rules of threads is to avoid global or shared state. Global or shared state means any global variables that you have in your code, as well as any state that your thread may access that other threads (also) might access.

If two or more threads access shared state without any kind of protection, this is known as a data race. A data race occurs when two threads want to perform different operations on a variable, and it just so happens that they do it the same time, or close enough that it doesn't matter. For example, if thread 1 wants to read a sound handle and another thread wants to initialize it, it may just so happen that both operations overlap, causing the handle that thread 1 gets to be in some weird undefined state. Data races can have all kinds of dangerous consequences that could make your program crash, cause unpredictable behavior, and so on. It's even known to cause a write to a variable to mysteriously vanish!

Data races are also one of the hardest things for a programmer to debug. This is because it can't be predicted when they'll even occur. One run of your code might be fine, but the next run might cause the race, or it might only occur every 200 runs of your code. This is why protection is so important.

### Protecting against data races

There are several ways of protecting your code against data races if you do share state:

* Locks or semaphores
* Atomic variables
* Events/condition variables
* Just don't share any state
* Message passing (which will be explained here after it is added to NVGT)

#### Locks and semaphores

A lock is a synchronization primitive used to manage access to a shared resource by multiple threads. When a thread wants to "acquire" the lock, it checks if another thread already holds it. If the lock is already acquired, the requesting thread is blocked until the lock becomes available. When the lock is released, the blocked thread can proceed. This mechanism prevents concurrent access to the resource, ensuring data consistency and integrity.

Semaphores are another important synchronization mechanism. A semaphore is a signaling mechanism that can be used to control access to a common resource by multiple threads in a concurrent system. Semaphores can be used to solve various synchronization problems, such as controlling access to a finite number of resources or coordinating the order of thread execution. Semaphores maintain a counter representing the number of available resources. Threads can increment the counter to signal the release of a resource or decrement it to wait for a resource. When the counter is zero, any thread attempting to decrement it is blocked until the counter is incremented by another thread.

There are several types of locks and synchronization mechanisms. One common type is the mutex, or mutual exclusion lock. A mutex ensures that only one thread can access a resource at a time. When a thread acquires a mutex, other threads attempting to acquire the same mutex are blocked until it is released. This is useful for protecting critical sections of code where shared resources are accessed or modified.

Spinlocks are another type of lock, where the thread repeatedly checks if the lock is available in a loop, or "spins," until it can acquire the lock. Spinlocks are efficient when the wait time is expected to be short, as they avoid the overhead of putting the thread to sleep and waking it up. However, they are not suitable for long wait times, as they consume CPU cycles while spinning.

Read-write locks, or RW locks, allow multiple threads to read a resource simultaneously but provide exclusive access for writing. This lock has two modes: read mode and write mode. Multiple readers can hold the lock concurrently, but a writer must wait until all readers have released the lock, and vice versa. This is particularly useful in scenarios where read operations are frequent and write operations are infrequent, as it allows for greater concurrency.

Recursive locks are designed to be acquired multiple times by the same thread without causing a deadlock. They keep track of the number of times they have been acquired by the thread and require the same number of releases to unlock completely. This is useful in scenarios where the same thread might need to re-enter a critical section of code.

Binary semaphores, also known as mutex semaphores, can have only two states: 0 or 1, representing locked or unlocked. They function similarly to mutexes but do not have ownership, meaning any thread can release them, not just the thread that acquired them. This is useful for simple synchronization tasks where the ownership of the lock is not important.

Lastly, counting semaphores can have a value greater than one, allowing them to manage a finite number of resources. They maintain a counter representing the number of available resources. Threads increment, or signal, the counter when a resource is released and decrement, or wait, the counter when a resource is acquired. This is useful for limiting access to a pool of resources, such as a fixed number of database connections.

##### Wait wait, deadlocks?

yeah, did I forget to tell you about those? A deadlock is where two or more threads are unable to proceed with their execution because each is waiting for the other to release a resource they need.

To understand deadlocks, consider an example where two threads, Thread A and Thread B, need access to two resources, Resource 1 and Resource 2. If Thread A acquires Resource 1 and Thread B acquires Resource 2, both threads might then try to acquire the resource held by the other. Thread A will wait for Resource 2 to be released by Thread B, while Thread B waits for Resource 1 to be released by Thread A. Since neither thread can release the resource it holds until it acquires the resource held by the other, they are both stuck, leading to a deadlock.

Four necessary conditions for a deadlock to occur are:

* At least one resource must be held in a non-shareable mode, meaning only one thread can use the resource at any given time.
* A thread holding at least one resource must be waiting to acquire additional resources currently held by other threads.
* Resources cannot be forcibly taken from the threads holding them; they must be released voluntarily by the holding thread.
* There must exist a set of threads such that each thread is waiting for a resource held by the next thread in the set, forming a circular chain.

Preventing or resolving deadlocks typically involves ensuring that at least one of these conditions cannot hold. Techniques include:

* Impose a strict order in which resources must be acquired and ensure that all threads adhere to this order.
* Allow deadlocks to occur, but have mechanisms to detect and recover from them, such as terminating one or more of the threads involved.
* Use algorithms that dynamically analyze resource allocation requests to ensure that they do not lead to deadlocks, such as the Banker's Algorithm.
* Implement timeouts for resource requests, forcing a thread to release its held resources if it cannot acquire the required resources within a certain period (this, by far, may be the easiest algorithm to implement).

#### Atomic variables

An atomic variable is a special type of variable used in concurrent programming to ensure that operations on the variable are completed without interruption. The key characteristic of atomic variables is that any operation performed on them -- such as reading, writing, or modifying -- must be completed entirely before any other operation can start. This means that the state of the variable is always consistent and predictable, even when multiple threads are accessing or modifying it simultaneously.

To understand this better, consider a scenario where multiple threads are trying to increment a shared counter variable. In a non-atomic scenario, one thread might read the value of the counter, and another thread might read the same value before the first thread has a chance to write the incremented value back, leading to both threads writing back the same value. This causes the counter to be incremented only once instead of twice, leading to incorrect results.

However, with an atomic variable, the increment operation is indivisible. This means that when one thread starts to increment the counter, no other thread can read or write to the counter until the increment operation is fully completed. The operation is guaranteed to either fully succeed or fail, but it cannot be partially completed. This prevents the problem of race conditions, where the outcome depends on the unpredictable sequence of thread execution.

Modern processors support atomic operations through special hardware instructions that ensure these operations are performed without interruption. These instructions include atomic read-modify-write operations, such as compare-and-swap (CAS) and fetch-and-add, which are used to implement atomic variables.

For example, consider the compare-and-swap (CAS) operation. It works by checking if the value of the variable is equal to an expected value. If it is, the value is replaced with a new value. If it isn't, the operation fails. This all happens in one atomic step, ensuring that no other thread can interfere between the check and the update.

#### Events/condition variables

Events are synchronization primitives used to signal between threads, allowing one thread to notify others about the occurrence of a specific condition. In the context of concurrency, an event can be set or reset, and threads can wait for an event to be set before proceeding. This is particularly useful when you need one or more threads to pause execution until a certain condition is met.

For instance, imagine a scenario where a worker thread is processing tasks from a queue. The worker thread can wait for an event that gets set when new tasks are added to the queue. Once the event is set, the worker thread wakes up and processes the new tasks. If there are no tasks, the worker thread goes back to waiting. This mechanism ensures efficient use of CPU resources, as the worker thread is not continuously polling the queue but instead waits for a signal.

Events can be manual-reset or auto-reset. A manual-reset event remains signaled until it is explicitly reset, allowing multiple waiting threads to be released. An auto-reset event automatically resets after releasing a single waiting thread, ensuring that only one thread is woken up per signal.

Condition variables are another synchronization mechanism used to block a thread until a particular condition is met. They are typically used in conjunction with mutexes. When a thread waits on a condition variable, it releases the associated mutex and enters a waiting state. When the condition is signaled, the mutex is reacquired, and the thread resumes execution.

The primary use case for condition variables is to manage complex thread interactions that require waiting for certain states or conditions. For example, in a producer-consumer scenario, a consumer thread might wait on a condition variable until there are items available in a buffer. The producer thread, after adding an item to the buffer, signals the condition variable to wake up the consumer thread.

Here’s a simplified example: a producer and consumer thread are started one after the other. The producer thread (which is what produces data for the consumer thread to act upon) acquires the mutex, adds an item to the buffer, signals the condition variable, and releases the mutex. By contrast, the consumer thread acquires the mutex, waits on the condition variable while the buffer is empty, processes the item from the buffer the condition variable has been signaled, and releases the mutex. The "mutex," in this  case, could (and should most likely be) a recursive mutex.

Condition variables support two main operations: `wait` and `notify`. The `wait` operation puts the thread into a waiting state and releases the mutex. The `notify_one` operation wakes up one waiting thread, while `notify_all` wakes up all waiting threads. These operations are critical for coordinating complex interactions and ensuring that threads only proceed when the required conditions are met.

Events are simpler to use when you need to signal one or more threads to proceed. They are particularly effective when dealing with straightforward signaling scenarios, such as waking up worker threads when a new task arrives.

Condition variables are more suitable for scenarios requiring complex synchronization, especially when multiple conditions and interactions between threads need to be managed. They provide more control over the waiting and signaling process, making them ideal for use cases like producer-consumer problems.

#### Not sharing any state

If all of the above has left you utterly confused and wondering what you've just read, that's okay; you have lots of other options. The simplest would be to just ignore this section entirely and to just not use threads at all. If you really, really, really do need threads, though, the best method would be to figure out how you don't need to share state. This might be quite difficult in some cases, but the less state you share, the less likely it is you'll need to worry about any of this stuff. If you do need to share state, all of the above is important to understand to do things properly.

### Creating and managing threads

To create a thread, call the `thread` constructor and give it a name of your thread. This is usually an ID that you can use to look up the thread later. This will NOT start your thread, though; to do that, call `start` passing in both a function to execute and (optionally) a dictionary handle of arguments that that thread should receive.

Your thread callback should take as input a `dictionary@` which contains the arguments given in `start()`.

Once started, a thread immediately begins execution. Your original code that spawned the thread will continue executing after this function returns.

If you want to wait until the thread completes, call `join()` without any arguments. Alternatively, `join` can take a timeout which, if expires, causes the function to return `false`.

On the thread object there are a few other things you can do as well, such as changing the threads priority via the `priority` property.

#### Warning!

Do not change the priority of a thread unless you absolutely have to. Messing around with the thread priority of a thread -- particularly with threads which do a lot of computationally expensive work -- can cause your entire system to hang and have other undesireable side-effects!

### Golden rules of threads

When using threads, always remember:

* Only use threads when you need to. Do not just use them because you feel they would make your code faster. More often than not, this will just cause your code to run slower.
* When using locks, hold the lock for the shortest time possible. The area in which a lock is acquired is known as a critical section, and you should do only what you neeed to do in these and then immediately release the lock. If you don't do this, you could cause resource leaks, sequential execution, deadlocks and all kinds of other problems.
* Do not acquire a lock at the start of a function. This may seem tempting, but it is wrong, and will cause your code to be far slower, if not eliminate the benefit of using threads entirely.
* Avoid recursive mutexes unless you know what you are doing.
* When acquiring a lock, there are two ways of doing so: `lock` and `try_lock`. If your able to, use `try_lock` which will return false if the lock cannot be acquired. If this does return false, go do something else and try acquiring the lock later.
* If your code consists of many threads that mostly perform reads of shared state and only a few cases where shared state is modified, use a reader-writer lock and not a mutually exclusive one.
* Do not mess with thread priorities.
* The less shared state your threads have to manage, the fewer synchronization issues you'll encounter. Where possible, avoid global variables or shared objects.
* For simple counters or flags, use atomic operations instead of locks to avoid the overhead and complexity of mutexes.
* Do not use busy-waiting (spinning) to wait for a lock or condition. This wastes CPU resources and can lead to performance issues. If you need to wait for a lock to be available for acquisition, call `lock` on it and allow the underlying operating system to do the waiting for you.
* Creating and destroying threads can be expensive. Reuse threads with thread pools or similar techniques to manage resources efficiently.
* Where possible, use higher-level concurrency constructs like `async<T>`. These abstractions often handle the complex details of synchronization for you.
* When using condition variables, always protect the condition check with a lock and use a loop to recheck the condition after waking up, as spurious wakeups can occur. That is, it is possible for your thread to be awoken when the condition variable hasn't actually been signaled.
* While using timeouts can prevent deadlocks, ensure that your program can handle the scenario where a timeout occurs gracefully.
* Clearly document the synchronization strategy in your code, including which locks protect which data. This helps maintainers understand the concurrency model and avoid introducing bugs.
* Concurrency bugs can be rare and hard to reproduce. Test your application under load to increase the chances of exposing synchronization issues early in development.

## Conclusion

This article provided a deep dive into the various concurrency mechanisms provided by NVGT. Though parts may have been terse, we still hope it helped. If you have any questions, don't hesitate to ask!
