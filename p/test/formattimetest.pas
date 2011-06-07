{ COMPILE-CMD: strftime.cmp }

program FormatTimeTest;

uses GPC;

{$include "rts-config.inc"}

{$ifdef HAVE_STRFTIME}
{$L formattc.c}
function CFormatTime (Time : LongInt; Format, Buf : CString; Size : Integer) : Integer; external name 'cstrftime';

function CFormatTimeP (const Time : TimeStamp; const Format : String) : TString;
var
  Buffer : array [0 .. 32 * Length (Format)] of Char;  { should always be sufficient, usually way too large }
  CRes : Integer;
begin
  CRes := CFormatTime (TimeStampToUnixTime (Time), Format, Buffer, SizeOf (Buffer));
  if CRes > 0
    then CFormatTimeP := Buffer [0 .. CRes - 1]
    else CFormatTimeP := ''
end;
{$endif}

const
  SimpleTestFormat = '%Y-%m-%d %H:%M:%S';
  ExtensionTestFormat = '%G';
  TestFormat1 =  { No extensions}
    '|%a|%A|%b|%B|%d|%H|%I|%j|%m|%M|%S|%U|%w|%W|%y|%Y|%%|';
  TestFormat2 =  { POSIX.2 and GNU extensions }
    '|%a|%A|%b|%h|%B|%C|%d|%D|%e|%g|%G|%H|%I|%j|%k|%l|%m|%M|%n|%p|%P' +
    '|%r|%R|%s|%S|%t|%T|%u|%U|%V|%w|%W|%y|%Y|%z|%%|%:|';

var
  Time : TimeStamp;
  TestFormat, s1, s2 : TString;
  DSTStartError, Done : Boolean;

begin
  with Time do
    begin
      DateValid := True;
      TimeValid := True;
      Year := 2001;
      Month := 12;
      Day := 31;
      Hour := 12;
      Minute := 3;
      Second := 17;
      if FormatTime (Time, SimpleTestFormat) <> '2001-12-31 12:03:17' then
        begin
          WriteLn ('failed: ', FormatTime (Time, SimpleTestFormat));
          Halt (1)
        end
    end;
  {$ifndef HAVE_STRFTIME}
  WriteLn ('SKIPPED: no strftime() in libc (FormatTime still works)');
  {$else}
  if CFormatTimeP (Time, '%P') = 'pm'
    then TestFormat := TestFormat2
    else TestFormat := TestFormat1;
  with Time do
    for Year := 1990 to 2010 do
      begin
        DSTStartError := False;
        for Month := 1 to 12 do
          for Day := 1 to MonthLength (Month, Year) do
            begin
              DateValid := True;
              TimeValid := True;
              Hour := Random (23);
              Minute := Random (60);
              Second := Random (60);
              repeat
                s1 := FormatTime (Time, TestFormat);
                s2 := CFormatTimeP (Time, TestFormat);
                Done := True;
                if s1 <> s2 then
                  if not DSTStartError then
                    begin
                      DSTStartError := True;  { Allow for one error per year if the time
                                                happens to fall in the hour skipped at the
                                                beginning of DST, ... }
                      Hour := (Hour + 12) mod 24;  { change the hour ... }
                      Done := False  { ... and try again }
                    end
                  else
                    begin
                      WriteLn ('failed (', Year, '-', Month, '-', Day, ' ', Hour, ':', Minute, ':', Second, '):');
                      WriteLn (s1);
                      WriteLn (s2);
                      Halt (1)
                    end
               until Done
            end
      end;
  WriteLn ('OK')
  {$endif}
end.
