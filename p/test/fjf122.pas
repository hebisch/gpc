program fjf122;
var time:TimeStamp;
begin
  GetTimeStamp(time);
{$if 0 }
  if time.datevalid then writeln(time.day,'.',time.month,'.',time.year)
                    else writeln('date???');
  if time.timevalid then writeln(time.hour,':',time.minute,':',time.second)
                    else writeln('time???')
{$else }
  if time.datevalid then
    with time do
      if not ( day in [ 1..31 ] ) and ( month in [ 1..12 ] ) and ( year in [ 1970..2100 ] ) then
        writeln ( 'invalid date' );
  if time.timevalid then
    with time do
      if not ( hour in [ 0..23 ] ) and ( minute in [ 0..59 ] ) and ( second in [ 0..61 ] ) then
        writeln ( 'invalid time' );
  writeln ( 'OK' );
{$endif }
end.
