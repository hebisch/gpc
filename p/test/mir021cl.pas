program mir021cl;
{procedure call with char out of bounds, lower}
uses GPC;
type range = 'c'..'j';
var k : Char;

procedure CallWithRange (c: range);
begin
end;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

begin
   AtExit(ExpectError);
   k:='a';
   {k bellow the range}
   CallWithRange (k);
end.
