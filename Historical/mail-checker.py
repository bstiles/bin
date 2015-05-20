#!/usr/bin/env python

import os
import urllib             # For BasicHTTPAuthentication
import feedparser         # For parsing the feed
import popen2
import re
import datetime
import cPickle
import htmlentitydefs

_WORK_DIR = '/Users/bstiles/Library/Application Support/Mail Checker/'
_URL = "https://mail.google.com/gmail/feed/atom"
_SEC_CMD = 'security find-internet-password -s smtp.gmail.com -a %s -g'
_MAX_AGE_DAYS = 8

##
# Removes HTML or XML character references and entities from a text string.
#
# @param text The HTML (or XML) source text.
# @return The plain text, as a Unicode string, if necessary.

def unescape(text):
    def fixup(m):
        text = m.group(0)
        if text[:2] == "&#":
            # character reference
            try:
                if text[:3] == "&#x":
                    return unichr(int(text[3:-1], 16))
                else:
                    return unichr(int(text[2:-1]))
            except ValueError:
                pass
        else:
            # named entity
            try:
                text = unichr(htmlentitydefs.name2codepoint[text[1:-1]])
            except KeyError:
                pass
        return text # leave as is
    return re.sub("&#?\w+;", fixup, text)

def get_password(user):
    p = popen2.Popen3(_SEC_CMD % user, True)
    status = p.wait()
    try:
        if os.WIFEXITED(status) and os.WEXITSTATUS(status) == 0:
            password = re.match('password: "(.*)"', p.childerr.read()).group(1)
            return password
    except Exception:
        pass
    return None

class MyUrlOpener(urllib.FancyURLopener):
    def __init__(self, user, password, *args, **kwargs):
        urllib.FancyURLopener.__init__(self, *args, **kwargs)
        self.__user = user
        self.__password = password
        self.__attempts = 0

    def prompt_user_passwd(self, host, realm):
        # The superclass is supposed to limited the number of failed retries
        # but doesn't when this method is overridden (inexplicably), so
        # I've implemented my own throttle.
        if self.__attempts > 3:
            raise Exception('Too many failed attempts for %s' % self.__user)
        self.__attempts += 1
        return self.__user, self.__password

def retrieve(user):
    password = get_password(user)
    if not password:
        raise Exception("Couldn't get password for %s" % user)
    opener = MyUrlOpener(user, password)
    f = opener.open(_URL)
    return f.read()

def meets_age_criteria(now, date):
    return (now - date).days < _MAX_AGE_DAYS
    
def get_seen(user, now):
    updated = False
    f = None
    seen = {}
    old_seen = None
    try:
        f = open(_WORK_DIR + user, 'r')
        old_seen = cPickle.load(f)
        for message_id, message_date in old_seen.items():
            if meets_age_criteria(now, message_date):
                seen[message_id] = message_date
    except:
        print "Couldn't open %s" % (_WORK_DIR + user)
        return {}
    finally:
        if f:
            f.close()
    if seen != old_seen:
        put_seen(user, seen)
    return seen

def put_seen(user, seen):
    f = None
    try:
        f = open(_WORK_DIR + user, 'wb')
        cPickle.dump(seen, f)
    except:
        print 'Problem writing "seen" for %s' % user
    finally:
        if f:
            f.close()

now = datetime.datetime.now()
for user in ('brian.stiles@gmail.com',
             'bstiles@bstiles.net',
             'brian@stilesre.com',
             'brians.subscriptions@stilesre.com'):
    seen = get_seen(user, now)
    feed = retrieve(user)
    atom = feedparser.parse(feed)
    updated = False
    for i in xrange(len(atom.entries)):
        entry = atom.entries[i]
        message_id = entry.id
        message_date = datetime.datetime(*entry.modified_parsed[:6])
        if meets_age_criteria(now, message_date):
            if not seen.has_key(message_id):
                os.spawnlp(os.P_NOWAIT,
                           '/usr/local/bin/growlnotify',
                           'growlnotify',
                           '--appIcon',
                           'GMail Notifier.app',
                           '-m',
                           'From: %s\n%s\n%s' % (entry.author_detail.name,
                                           unescape(entry.title),
                                           unescape(entry.summary)),
                           '-t',
                           user)
                seen[message_id] = message_date
                updated = True
    if updated:
        put_seen(user, seen)
