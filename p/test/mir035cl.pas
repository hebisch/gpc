program mir035cl;
{pack range test}
uses GPC;
type range = 'c'..'j';
var arry : array [range] of Char;
    parry : packed array [range] of Char;
    k    : Char;

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
   Pack (arry, k, parry);
   {k under the range}
end.
