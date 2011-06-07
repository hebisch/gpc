program testMT;
uses GPC;
const
   big = 10000000;
   TimeFormat = ' %Q';
var
   t1, t2  : medCard;
   CurrentTime   : TimeStamp;

begin
   GetTimeStamp (CurrentTime);
   WriteStr(FormatTime(CurrentTime, TimeFormat), t1);       { line 17 }  { WRONG }
   GetTimeStamp (CurrentTime);
   WriteStr(FormatTime(CurrentTime, TimeFormat), t2);
   Writeln('Elapsed time: ', (t2 - t1):1);
end.
