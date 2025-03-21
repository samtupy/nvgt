# array
This container stores a resizable list of elements that must all be the same type. In this documentation, "T" refers to the dynamic type that a given array was instanciated with.
1. `T[]();`
2. `array<T>();`
3. `array<T>(uint count);`
4. `array<T>({item1, item2, item3})`

## Arguments (3):
* uint count: The initial number of items in the array which will be set to their default value upon array instanciation.

## Arguments (4):
* {item}: A list of elements that the array should be initialized with.

## Remarks:
Items in an array are accessed using what's known as the indexing operator, that is, `arrayname[index]` where index is an integer specifying what item you wish to access within the array. The biggest thing to keep in mind is that unlike many functions in NVGT which will silently return a negative value or some other error form upon failure, arrays will actually throw exceptions if you try accessing data outside the array's bounds. Unless you handle such an exception with a try/catch block, this results in an unhandled exception dialog appearing where the user can choose to copy the call stack before the program exits. The easiest way to avoid this is by combining your array accesses with healthy usage of the array.length() method to make sure that you don't access out-of-bounds data in the first place.

Data in arrays is accessed using 0-based indexing. This means that if 5 items are in an array, you access the first item with `array[0]` and the last with `array[4]`. If you are a new programmer this might take you a second to get used to, but within no time your brain will be calculating this difference for you almost automatically as you write your code, it becomes second nature and is how arrays are accessed in probably 90+% of well known programming languages. Just remember to use `array[array.size() -1]` to access the last item in the array, not `array[array.length()]` which would cause an index out of bounds exception.

There is a possible confusion regarding syntax ambiguity when declaring arrays which should be cleared up. What is the difference between `array<string> items` and `string[] items` and when should either one be used?

At it's lowest level, an array is a template class, meaning it's a class that can accept a dynamic type `(array<T>)`. This concept also exists with the grid, async, and other classes in NVGT.

However, AngelScript provides a convenience feature called the default array type. This allows us to choose just one template class out of all the template classes in the entire engine, and to make that 1 class much easier to declare than all the others using the bracket syntax `(T[])`, and this array class happens to be our chozen default array type in NVGT.

Therefore, in reality `array<T>` and `T[]` do the exact same thing, it's just that the first one is the semantically correct method of declaring a templated class while the latter is a highly useful AngelScript shortcut. So now when you're looking at someone's code and you see a weird instance of `array<T>`, you can rest easy knowing that you didn't misunderstand the code and no you don't need to go learning some other crazy array type, that code author just opted to avoid using the AngelScript default array type shortcut for one reason or another.
