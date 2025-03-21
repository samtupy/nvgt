# Contributing
Contributions to NVGT are extremely welcome and are what help the project grow. If you want to contribute, please keep the following things in mind.

## issues
If you've discovered a bug, please open a GitHub issue so we can try to fix it. However, please keep the following in mind when you do so:
1. Please check the [Blog](https://nvgt.gg/blog/), the todo list and the existing list of issues and pull requests in case a record of the problem already exists, avoiding duplicate reports is appreciated.
2. Please avoid 1 or 2 sentence issues such as "The speak function isn't working" or "Compiled script won't run on my Mac." At the moment there is not much strictness in how issues must be written, however it is asked that you please put some effort into your issue descriptions E. if code doesn't work how you expect, please provide preferably a sample or at least steps to reproduce, or if something won't run, please provide preferably debug output like a stack trace or at least platform details and/or an exact error message.
3. Please keep your issue comments strictly on topic, and try editing them rather than double posting if you come up with an amendment to your comment shortly after posting it. Avoid repeated queries.
4. If you have a question rather than a bug to report, please open a discussion rather than an issue.

## Pull Requests
Pull requests are also very welcome and are generally the quickest path to getting a fix into NVGT. If you wish to submit one, please keep the following things in mind:
1. Respect the coding style: While little mistakes are OK (we can fix them with an auto formatter), please do not completely disregard it. Unindented code or code without padded operators etc is not appreciated.
2. Find an existing way to perform a standard operation before implementing your own version: For example if you need to encode a string into UTF8, realize that other code in NVGT likely needs to do this as well, and figure out how NVGT already does it rather than writing your own UTF8 encoding function. This keeps the code cleaner and more consistent, someone won't come along in the future and wonder what method they should use to encode a string into UTF8.
3. Though it is not absolutely required, it is usually a good idea to open a discussion or issue before a pull request that introduces any kind of very significant change is created. This should absolutely be done before any sort of dependency addition or change. Pull requests that do not adhere to this may be delayed or denied.
4. Please check the Blog and the todo list before opening a pull request, in case we have noted a certain way we wish to do something that your pull request might go against.
5. If you modify the C++ code, please try making sure it builds on as many platforms that we support as you have access to. For example you can build NVGT on Linux using WSL on Windows. You only need to worry about this within reason, but any work you can do here is seriously appreciated.
6. Regardless of whether you modify C++ code or NVGT includes, please be very careful that you do not change the existing API in any way that would cause existing NVGT code to stop running without a discussion first. Even if such breaking changes are approved, they are to be clearly documented.
7. If you contribute to the documentation, please try to run the docgen.py script and make sure your changes basically compile, and then open the HTML version of the compiled documentation and make sure it looks OK before committing. Please follow the existing documentation source structure to the best of your ability when writing topics.
8. Understand that any contributions to the project are to be put under the same license that NVGT is released under, which is Zlib, or any other acceptable license. It is OK to add a credit to yourself for large portions of source code you contribute, but the general copyright notice is to remain the same. For the avoidance of doubt, the term "acceptable license," as used herein, means:
    1. Any license which is compatible with the Zlib license;
    2. Any license which requires only source code attribution or conditional attribution and does not mandate binary attribution; and
    3. Any license which employs non-viral copyleft measures, such as file-based copyleft, when such measures do not extend to the entire project or derivative works created by end-users.
    If you wish to add code or a dependency that requires binary attribution, please start a discussion to get approval first. This gives us time to evaluate how it might affect downstream users, since such attribution impacts everyone regardless of who they are or their experience level. We aim to avoid placing this burden on downstream users, but we recognize that it might not always be possible.

Please note that these guidelines may be updated at any time. Thanks for your interest in contributing!