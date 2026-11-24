# Replaces the first 2 bytes of a stub with NV. Run in script mode: cmake -DFILE=<stub> -P NvgtStampStub.cmake
# On Windows a stub starting with the MZ header gets some sort of extra antivirus scan whenever a script is compiled with it, which makes compiling take a bit longer. On macOS Apple's notarization service detects the stub as an unsigned binary and fails. Stubs must be unsigned until the NVGT scripter signs their compiled games.
# NVGT - NonVisual Gaming Toolkit (https://nvgt.dev)
# Copyright (c) 2022-2026 Sam Tupy
# license: zlib

if(CMAKE_HOST_WIN32)
	string(REPLACE "'" "''" path "${FILE}")
	execute_process(COMMAND powershell -NoProfile -NonInteractive -Command "$f = [IO.File]::Open('${path}', 'Open', 'ReadWrite'); $f.Write([byte[]](78, 86), 0, 2); $f.Close()" RESULT_VARIABLE result)
else()
	execute_process(COMMAND sh -c "printf NV | dd of=\"$1\" bs=1 count=2 conv=notrunc 2>/dev/null" sh "${FILE}" RESULT_VARIABLE result)
endif()
if(NOT result EQUAL 0)
	message(FATAL_ERROR "Could not write the NV header to ${FILE}.")
endif()
