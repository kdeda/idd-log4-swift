# Log4swift

Simple logging API for Swift platforms.
Inspired by https://github.com/jduquennoy/Log4swift
However these guys do not support swift package manager yet. (March 2021)

## Log Spamming
To block spamming messages, ie: CVDisplayLinkStart and stuff

Run Console.app
Start streaming
Filter for your noise ie: CVDisplayLinkStart
Locate the Subsystem ie: com.apple.corevideo

Now tell log config to block these.
sudo log config --mode "level:off" --subsystem com.apple.corevideo

Version 1.2.5 starting from April 7, 2023 will be placed in hospice and should not be used on newer projects. 
It will get fixes only if anything major breaks. 
We advise users to move to version 2.x.x as soon as possible.

Version 2.x.x, starting March 2023 is implemented in pure swift, using apple/swift-log.git, so it compiles on Linux/Windows, no more Objective-C.
We advise users to move to version 2.x.x as soon as possible.
