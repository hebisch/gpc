program fsc05;
{array 2 dimensions read}
uses GPC;
type arr = array[1..3,1..3]of Char;
var a  : arr;
   i,j : Integer;
   c   : Char;
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
   for i:=1 to 3 do
      for j:=1 to 3 do
         a[i,j]:='a';
   i:=4; j:=1;
   {reading outside a 2 dimensions array}
   c:=a[i,j];
end.
