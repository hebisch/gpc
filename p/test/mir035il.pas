program mir035il;
{pack range test}
uses GPC;
type range = 12..42;
var arry  : array [range] of Char;
    parry : packed array [range] of Char;
    k     : Integer;

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
   k:=10;
   Pack (arry, k, parry);
   {k under the range}
end.
