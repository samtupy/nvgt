# mutex_lock
Lock a mutex until the current execution scope exits.

1. `mutex_lock(mutex@ mutex_to_lock);`
2. `mutex_lock(mutex@ mutex_to_lock, uint milliseconds);`

## Arguments (2):
	* uint milliseconds: The amount of time to wait for a lock to acquire before throwing an exception.

## Remarks:
Often it can become tedious or sometimes even unsafe to keep performing mutex.lock and mutex.unlock calls when dealing with mutex, and this object exists to make that task a bit easier to manage.

This class takes advantage of the sure rule that, unless handles become involved, an object created within a code scope will be automatically destroyed as soon as that scope exits.

For example:

```
if (true) {
	string s = "hello";
} // the s string is destroyed when the program reaches this brace.
```

In this case, the constructor of the mutex_lock class will automatically call the lock method on whatever mutex you pass to it, while the destructor calls the unlock method. Thus, you can lock a mutex starting at the line of code a mutex_lock object was created, which will automatically unlock whenever the scope it was created in is exited.

The class contains a single method, void unlock(), which allows you to unlock the mutex prematurely before the scope actually exits.

There is a very good reason for using this class sometimes as opposed to calling mutex.lock directly. Consider:

```
my_mutex.lock();
throw("Oh no, this code is broken!");
my_mutex.unlock();
```

In this case, mutex.unlock() will never get called because an exception got thrown meaning that the rest of the code down to whatever handles the exception won't execute! However we can do this:

```
mutex_lock exclusive(my_mutex);
throw("Oh no, this code is broken!");
exclusive.unlock()
```

The mutex_lock object will be destroyed as part of the exception handler unwinding the stack, because the handler already knows to destroy any objects it encounters along the way. However any code that handles exceptions certainly does not know it should specifically call the unlock method of a mutex, thus you could introduce a deadlock in your code if you lock a mutex and then run code that throws an exception without using this mutex_lock class.

A final hint, it is actually possible to create scopes in Angelscript and in many other languages as well without any preceding conditions, so you do not need an if statement or a while loop to use this class.

```
int var1 = 2;
string var2 = "hi";
{
	string var3 = "catch me if you can...";
}
string var4 = "Hey, where'd var3 go!";
```
