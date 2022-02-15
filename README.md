# Log4swift

Depended on  https://github.com/jduquennoy/Log4swift

But these guys do not support swift package manager yet. (March 2021)

To update (this was done on 1.2.0), cd somewhere

git clone https://github.com/jduquennoy/Log4swift

open the Log4swift.xcodeproj and drop all the .h, .m files, all legacy before 10.12 and ios13 appenders

once we can compile with no errors move the Log4swift/Log4swift into our package

## Log Spamming
To block spamming messages, ie: CVDisplayLinkStart and stuff

Run Console.app
Start streaming
Filter for your noise ie: CVDisplayLinkStart
Locate the Subsystem ie: com.apple.corevideo

Now tell log config to block these.
sudo log config --mode "level:off" --subsystem com.apple.corevideo

