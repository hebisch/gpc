program mir042u;
uses GPC;
{function fillChar }
type CharArr = array [1..10] of Char;
var c : CharArr;
   i,k  : Integer;
procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end; { ExpectError }
begin
   AtExit(ExpectError);
   i:=10;
   k:=Ord (MaxChar) + 1;
   FillChar(c,i,k);
end.
