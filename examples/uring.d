/++ dub.sdl:
	name "uring-example"
	description "this does nothing, but also does not crash"
	dependency "eventcore" path=".."
	versions "UringEventLoopDebug"
	debugVersions "UringEventLoopDebug"
+/
import std.stdio;
import core.time;
import std.string;

import eventcore.drivers.posix.epoll;
import eventcore.drivers.posix.io_uring.io_uring;
import eventcore.drivers.posix.io_uring.files;
import eventcore.driver;

import std.datetime.stopwatch;

void main()
{
	StopWatch sw;
	sw.start();
	auto drv = new EpollEventDriver();
	auto files = drv.files;

	auto fd = files.open("/tmp/testfile", FileOpenMode.createTrunc);
	assert (files.isValid(fd));
	files.write(fd, 0, "this is a testwrite".representation, IOMode.init,
		(FileFD file, IOStatus status, size_t written)
		{
			try {writefln("write: %s, %s, %s, %s", file, fd, status, written);}
			catch(Exception e) {}
		}
	);
	ExitReason r = drv.core.processEvents(Duration.max);
	writeln(r);
	//assert (r == ExitReason.idle);
	ubyte[256] buffer;
	files.read(fd, 0, buffer[], IOMode.init,
		(FileFD file, IOStatus status, size_t read)
		{
			try {
				writefln("read: %s, %s, %s, %s", file, fd, status, read);
				writeln(cast(char[]) buffer[0 .. read]);
			}
			catch(Exception e) {}
		}
	);
	writeln(drv.core.processEvents(Duration.max));
	files.read(fd, 0, buffer[], IOMode.init,
		(FileFD file, IOStatus status, size_t read)
		{
			try {
				writefln("read: %s, %s, %s, %s", file, fd, status, read);
				writeln(cast(char[]) buffer[0 .. read]);
			}
			catch(Exception e) {}
		}
	);
	files.write(fd, 19, "this is a snd testwrite".representation, IOMode.init,
		(FileFD file, IOStatus status, size_t written)
		{
			try {writefln("write: %s, %s, %s, %s", file, fd, status, written);}
			catch(Exception e) {}
		}
	);
	writeln(drv.core.processEvents(Duration.max));
}
