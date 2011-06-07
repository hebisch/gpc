program mir021cu;
{procedure call with char out of bounds, upper}
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
   k:='n';
   {k above the range of char}
   CallWithRange (k);
end.
