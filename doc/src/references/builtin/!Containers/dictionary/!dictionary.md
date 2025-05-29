# dictionary
This container stores multiple pieces of data of almost any type, which are stored and referenced by unique keys which are just arbitrary strings.
1. `dictionary();`
2. `dictionary({{"key1", value1}, {"key2", value2}});`

## Arguments (2):
* {{"key", value}}: default values to set in the dictionary, provided in the format shown.

## Remarks:
The idea behind a dictionary, or hash map / hash table as they are otherwise called, is that one can store some data referenced by a certain ID or key, before later retrieving that data very quickly given that same key used to store it.

Though explaining the details and guts of how hash maps work internally is beyond the scope of this documentation, here is an [overly in depth wikipedia article](https://en.wikipedia.org/wiki/Hash_table) that is sure to teach you more than you ever wished to know about this data structure. Honestly unless you wish to write your own dictionary implementation yourself in a low level language and/or are specifically worried about the efficiency of storing vast amounts of similar data which could stress the algorithm, it is enough to know that the dictionary internally turns your string keys into integer hashes, which are a lot faster for the computer to compare than the characters in the key strings themselves. Combine this with clever use of small lists or buckets determined by even more clever use of bitwise operations and other factors, and what you are left with is a structure that can store thousands of keys while still being able to look up a value given a key so quickly it is like magic, at least compared to the least efficient alternative which is looping through your thousands of data points and individually comparing them in order to find just one value you wish to look up.

NVGT's dictionaries are unordered, meaning that the get_keys() method will likely not return a list of keys in the order that you added them. In cases where this is very important to you, you can create a string array along side your dictionary and manually store key names yourself and then loop through that array instead of the output of get_keys() when you want to enumerate a dictionary in an ordered fassion. Note, of course, that this makes the entire system less efficient as now deleting or updating a key in the dictionary requires you to loop through your string array and find the key that needs deleting or updating, and dictionaries exist exactly to avoid such an expensive loop, though the same efficiency is preserved when simply looking up a key in the dictionary without writing to it, which can be enough in many cases. While in most cases it is best to write code that does not rely on the ordering of items in a dictionary, this at least provides an option to choose between ordering and better efficiency, should you really need such a thing.

Look at the individual documented methods of this class for examples of its usage.
