# Concurrency
This section contains the documentation for all mechenisms revolving around several things running at once, usually involving threads and their related synchronization facilities.

A warning that delving into this section will expose you to some rather low level concepts, the misapplication of which could result in your program crashing or acting oddly without the usual helpful error information provided by NVGT.

The highest level and most easily invoqued method for multithreading in nvgt is the async template class, allowing you to call any script or system function on another thread and retrieve it's return value later.
