program fsc09;
{packed array 2 dimensions write}
uses GPC;
type arr = packed array[1..3,1..3]of Char;
var a  : arr;
   i,j : Integer;

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
   i:=4; j:=1;
   {writing outside a 2 dimensions packed array}
   a[i,j]:='a';
end.
