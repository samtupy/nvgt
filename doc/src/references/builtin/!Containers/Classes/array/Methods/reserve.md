# reserve
allocates the memory needed to hold the given number of items, but doesn't initialize them.

`void array::reserve(uint length);`

## Arguments:
* uint length: the size of the array you want to reserve.

## Remarks:
This method is provided because in computing, memory allocation is expensive. If you want to add 5000 elements to an array and you call array.insert_last() 5000 times without calling this reserve() method, you will also perform nearly 5000 memory allocations, and each one of those is a lot of work for the OS. Instead, you can call this function once with a value of 5000, which will perform only one expensive memory allocation, and now at least for the first 5000 calls to insert_last(), the array will not need to repetitively allocate tiny chunks of memory over and over again to add your intended elements. The importance of this cannot be stressed enough for large arrays, using the reserve() method particularly for bulk array inserts can literally speed your code up by hundreds of times in the area of array management.
