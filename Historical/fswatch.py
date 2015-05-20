#!/usr/bin/env python

from fsevents import Observer, Stream
import os, sys, subprocess, threading, traceback

event = threading.Event()

def callback(path, mask):
    event.set()

def main():
    command = []
    paths = []
    run_on_start = False

    if '--' in sys.argv:
        start = 1
        if sys.argv[1] == '--run-on-start':
            start = 2
            run_on_start = True
        command = sys.argv[start:sys.argv.index('--')]
        paths = sys.argv[sys.argv.index('--') + 1:]
    if len(command) < 1 or len(paths) < 1:
        print 'usage: %s [--run-on-start] command [args..] -- path [path..]' % os.path.basename(__file__)
        print '  --run-on-start     Runs the command immediately and then waits'
        print '                     for change notification to run subsequently.'
        print '                     If this option is not present, the command will'
        print '                     not run until a change notification occurs.'
        print
        print 'Watches directories specified as path arguments for any changes'
        print 'within those directory trees and executes command. Change '
        print 'notifications are coalesced while the command is running so'
        print 'that the command will run again after the current command finishes.'
        sys.exit(0)

    for p in paths:
        if not os.path.isdir(p):
            print '%s is not a directory!' % p
            sys.exit(1)

    observer = Observer()
    stream = apply(Stream, [callback] + paths)
    observer.schedule(stream) 
    observer.start()

    if run_on_start:
        event.set()

    while observer.isAlive():
        try:
            if event.wait(1):
                try:
                    event.clear()
                    subprocess.call(command)
                except:
                    traceback.print_exc()
                    raise
        except:
            observer.stop()

if __name__ == '__main__':
    main()
