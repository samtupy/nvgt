# NVGT tests
This test directory contains the following folders:
* bench: standalone tests intended to specifically measure the performance of something
* case: generic test cases which all throw an exception on failure, executed by our test runner application
* data: static data used by any tests that require it
* interact: standalone test cases that require input from the user for useful results
* quick: standalone test cases with little convension, intended as a precursor to more official test cases for a new feature
* tmp: scratch directory ignored by version control which test cases can read and write to so that filesystem operations can be tested
* tests.nvgt: runner application that executes everything in the case directory, `nvgt tests.nvgt` for all cases or `nvgt tests.nvgt -- -h` for help.

The test runner application can either be executed  from the command line or NVGT's UI program, however it must be run from source along side a valid case directory.

The determining factor for whether a quick test belongs in the quick folder vs. the interact folder is whether the test requires extensive input from the user. So if a test shows just some alert boxes, it's fine in the quick folder. If the user needs to press keys in an nvgt window though, it probably belongs in interact.

Our official test case coverage is still relatively weak though many more quick tests do exists, so any new test case contributions are appreciated for anyone interested!
