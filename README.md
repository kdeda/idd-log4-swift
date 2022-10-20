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

