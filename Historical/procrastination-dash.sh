#!/usr/bin/env /usr/bin/python

import os
import locale
import random
import stat
import string
import sys
import time
import traceback

bin_dir = os.path.dirname(sys.argv[0])

data_path = '/Users/Shared/procrastinate'
if not os.path.exists(data_path):
    sys.exit(0)

modified_time = os.stat(data_path)[stat.ST_MTIME]
data_file = file(data_path)
operation = string.strip(data_file.read())
data_file.close()

if operation == 'work':
    if time.time() - modified_time < 3 * 60:
        sys.exit(0)
elif operation == 'break':
    if time.time() - modified_time < 17 * 60:
        sys.exit(0)

data_file = file(data_path, 'w')
if operation == 'work':
    data_file.write('break')
elif operation == 'break':
    data_file.write('work')
data_file.flush()
data_file.close()
os.system('osascript %s/procrastination-dash.scpt %s' % (bin_dir, operation))
sys.exit(0)
