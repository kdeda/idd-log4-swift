# Log4swift

Depended on  https://github.com/jduquennoy/Log4swift

But these guys do not support swift package manager yet. (March 2021)

To update (this was done on 1.2.0), cd somewhere

git clone https://github.com/jduquennoy/Log4swift

open the Log4swift.xcodeproj and drop all the .h, .m files, all legacy before 10.12 and ios13 appenders

once we can compile with no errors move the Log4swift/Log4swift into our package

 

