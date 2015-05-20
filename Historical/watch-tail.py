#!/usr/bin/env python
import sys
import os
import popen2
import signal

_appname = 'watch-tail.py'
logfilepath = '/tmp/java.log'

if len(sys.argv) == 3:
    logfilepath = sys.argv[2]
elif len(sys.argv) < 2 or len(sys.argv) > 3:
    print 'usage: %s pattern [file]' % sys.argv[0]
    sys.exit(0)
pattern = sys.argv[1]


def notify(s):
    os.system('/Users/bstiles/bin/growlnotify -m "%s" %s' % (s, _appname))

tail = popen2.Popen4('tail -f %s' % logfilepath)
found = None
try:
    line = tail.fromchild.readline()
    while line:
        if line.find(pattern) != -1:
            notify(line)
            found = 1
            break

        line = tail.fromchild.readline()
    if tail.fromchild.closed:
        notify('%s is closed' % logfilepath)
finally:
    os.kill(tail.pid, signal.SIGTERM)
    if not found:
        notify('%s is finished' % _appname)
    
