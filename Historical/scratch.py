import sys

import org.hsqldb.jdbcDriver

from java.lang import System
from java.sql import DriverManager

if not globals().has_key('connection') or globals()['connection'] is None:
    connection = DriverManager.getConnection('jdbc:hsqldb:hsql://localhost/logging', 'sa', '')
    print 'opened connection'
log_table = 'JdbcHandler'
statement = connection.createStatement()

def flush_messages(message, count):
    if count > 1:
        print '%s (%s times)' % (message, count)
    else:
        print message

def get_row_object(row, column_count):
    s = ''
    for x in range(column_count):
        if x > 0:
            s += " | "
        s = '%s%s' % (s, row.getObject(x + 1))
    return s

def clear_log():
    statement.execute('delete from %s where rowID in (select top 5 rowID from %s order by rowID)' % (log_table, log_table))

times = []
rules = []
row_ids = []
def act_on_row(rs):
    if 1:
        return
    try:
        if rs.getString('methodname') == 'beforeActivationFired':
            times.append(rs.getLong('millis'))
            rules.append(rs.getString('message'))
            row_ids.append(rs.getInt('rowid'))
        else:
            if rules[-1] != rs.getString('message'):
                raise '%s != %s' % (rule, last_rule)
            begin = times.pop()
            times.append(rs.getLong('millis') - begin)
            begin_row_id = row_ids.pop()
            row_ids.append((begin_row_id, rs.getInt('rowid')))
    except:
        print 'act_on_row failed'

def analyze_times():
    m = {}
    for x in range(len(times)):
        if times[x] > 9:
            print row_ids[x], times[x], rules[x]

def print_results(rs):
    metadata = rs.metaData
    columns = metadata.columnCount

    for x in range(columns):
        print metadata.getColumnName(x + 1), ', ',
    print

    count = 1
    s = None
    if rs.next():
        act_on_row(rs)
        last = get_row_object(rs, columns)
        while rs.next():
            act_on_row(rs)
            s = get_row_object(rs, columns)
            if last == s:
                count += 1
            else:
                flush_messages(last, count)
                count = 1
            last = s
        else:
            s = last

    flush_messages(s, count)
    return rs

try:
    five_minutes_ago = System.currentTimeMillis() - 5 * 60 * 1000
    limit = ""
    columns = "message_stripped, count(*) call_count, avg(cast(parameters as int)) average_time"#"rowid, millis, methodname, message"
##     columns = "message_stripped, parameters"#"rowid, millis, methodname, message"
    table = "(select coalesce(substring(message, 0, (locate('@', message) - 1)), message) message_stripped, * from %s)" % log_table
##     where = "where methodname like '%%ActivationFired' and level != 'SEVERE' and rowid >= (select max(rowid) from %s where methodname = 'fireRules' and message = 'begin')" % log_table
##     where = "where millis > %s" % five_minutes_ago
    where = "where message is not null and message like 'end%%' and parameters not like '!%%'"
    order_by = "group by methodname, message_stripped order by average_time asc"
##     order_by = "order by message_stripped asc"
    print "select %s %s from %s %s %s" % (limit, columns, table, where, order_by)
    rs = statement.executeQuery("select %s %s from %s %s %s" % (limit, columns, table, where, order_by))
    print_results(rs)
    rs.close()
    rs = statement.executeQuery("select * from %s where parameters like'!%%'" % (log_table,))
    print_results(rs)
    rs.close()
    rs = statement.executeQuery("select count(*) from %s %s" % (log_table, where))
    print_results(rs)
    rs.close()
    
except:
    connection.close()
    connection = None
    print 'connection aborted!'
    raise

analyze_times()
