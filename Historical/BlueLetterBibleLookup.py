#!/usr/bin/env python

import os
import sys
import webbrowser
import re

verse_pattern = re.compile('((?:[123])? *[A-z]+) *([0-9]+)(:([0-9]+))?')
url_base = 'http://www.blueletterbible.org/tools/printerFriendly.cfm?t=NASB'
url_book = '&b=%s'
url_chapter = '&c=%s'
url_verse = '&v=%s'

if len(sys.argv) < 2:
    os.system('growlnotify -t "Blue Letter Bible Lookup" -m "Argument required"')
    sys.exit(0)

search_term = sys.argv[1]

m = verse_pattern.match(search_term)
if not m:
    os.system('growlnotify -t "Blue Letter Bible Lookup" -m "Can\'t parse search term %s"' % search_term)
    sys.exit(0)

url = url_base + url_book % m.group(1).replace(' ', '') + url_chapter % m.group(2)
if m.group(4):
    url = url + url_verse % m.group(4)
else:
    url = url + url_verse % 1

if url:
    print url
    webbrowser.open_new(url)
