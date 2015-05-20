#!/usr/bin/env python

import os
import select
import socket
import sys

BUF_SIZE = 4096

usage = '''usage: %s [--help] [--port number]
--help           print this message
--port number    connect on this port number
''' % (len(sys.argv[0]) > 0 and sys.argv[0][(sys.argv[0].rindex('/') + 1):] or '')

if '--help' in sys.argv:
    print usage
    exit()

port = 8999

if '--port' in sys.argv:
    port = int(sys.argv[sys.argv.index('--port') + 1])
    if len(sys.argv) != 3:
        print usage
        exit()
else:
    if len(sys.argv) > 1:
        print usage
        exit()

stdin = None
stdout = None
stderr = None
            
try:
    stdout = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    stdout.connect(('localhost', port))
    stdout.sendall('session\n')
    f = stdout.makefile('r')
    try:
        session_id = f.readline()
    finally:
        f.close()
    stdout.setblocking(0)

    stdin = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    stdin.connect(('localhost', port))
    stdin.sendall('in\n')
    stdin.sendall('%s\n' % session_id)
    stdin.setblocking(0)

    stderr = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    stderr.connect(('localhost', port))
    stderr.sendall('err\n')
    stderr.sendall('%s\n' % session_id)
    stderr.setblocking(0)

    retries = 5
    inputs = [stdin, stdout, stderr, sys.stdin]
    excepts = [stdin, stdout, stderr]
    while retries:
        try:
            if len(inputs) == 4:
                inputready, outputready, exceptready = select.select(inputs, [], excepts)
            else:
                inputready, outputready, exceptready = select.select(inputs, [], excepts, 1.0)
                retries -= 1
            for s in inputready:
                if s == stdout and not s in exceptready:
                    data = stdout.recv(BUF_SIZE)
                    sys.stdout.write(data)
                    sys.stdout.flush()
                    if not data:
                        inputs.remove(stdout)
                if s == stderr and not s in exceptready:
                    data = stderr.recv(BUF_SIZE)
                    sys.stderr.write(data)
                    sys.stderr.flush()
                    if not data:
                        inputs.remove(stderr)
                if s == stdin and not s in exceptready:
                    data = stdin.recv(BUF_SIZE)
                    stderr.sendall(data)
                    stdout.sendall(data)
                    if not data:
                        inputs.remove(stdin)
                if s == sys.stdin:
                    data = sys.stdin.readline()
                    stdin.sendall(data)
        except:
            print 'exception', sys.exc_info()
            break

finally:
    if stdout is not None:
        stdout.close()
    if stdin is not None:
        stdin.close()
    if stderr is not None:
        stderr.close()
