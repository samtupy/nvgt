# opIndex
Set or retrieve the value of a dictionary by its key.
`int opIndex(* const string &in key);`

## Arguments:
* const string &in key: the key to use.

## Remarks:
If the key doesn't exist in the dictionary, it will be created, similar to using the set method.

If the key already exists, its value will be overwritten.

A value can be set as follows:

```
my_dictionary["key"]=value;
```

A value can be retrieved, but requires explicit casting, as follows:

```
string string_value=string(my_dictionary["key_for_string_value"]);
int int_value=int(my_dictionary["key_for_int_value"]);
obj@ object_value=cast<obj>(my_dictionary["key_for_object_value"]);
```
