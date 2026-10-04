define i64 @j_time_year_days(i64 %year) {
entry:
  %r4 = srem i64 %year, 4
  %r100 = srem i64 %year, 100
  %r400 = srem i64 %year, 400
  %four = icmp eq i64 %r4, 0
  %century = icmp eq i64 %r100, 0
  %fourcenturies = icmp eq i64 %r400, 0
  %ordinary = xor i1 %century, true
  %exception = or i1 %ordinary, %fourcenturies
  %leap = and i1 %four, %exception
  %days = select i1 %leap, i64 366, i64 365
  ret i64 %days
}

define i64 @j_time_iso_week(i64 %year, i64 %yearday, i64 %weekday, ptr %weekyear) {
entry:
  %sunday = icmp eq i64 %weekday, 0
  %dow = select i1 %sunday, i64 7, i64 %weekday
  %delta = sub i64 4, %dow
  %thursday = add i64 %yearday, %delta
  %before = icmp slt i64 %thursday, 0
  br i1 %before, label %previous, label %checknext
previous:
  %prior = sub i64 %year, 1
  %priorlength = call i64 @j_time_year_days(i64 %prior)
  %priorday = add i64 %thursday, %priorlength
  br label %finish
checknext:
  %length = call i64 @j_time_year_days(i64 %year)
  %after = icmp sge i64 %thursday, %length
  %nextyear = add i64 %year, 1
  %nextday = sub i64 %thursday, %length
  %selectedyear = select i1 %after, i64 %nextyear, i64 %year
  %selectedday = select i1 %after, i64 %nextday, i64 %thursday
  br label %finish
finish:
  %actualyear = phi i64 [%prior, %previous], [%selectedyear, %checknext]
  %actualday = phi i64 [%priorday, %previous], [%selectedday, %checknext]
  %weekzero = sdiv i64 %actualday, 7
  %week = add i64 %weekzero, 1
  store i64 %actualyear, ptr %weekyear
  ret i64 %week
}
