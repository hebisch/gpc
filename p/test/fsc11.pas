program fsc11;
{array in a record read}
uses GPC;
type arr = array[1..3]of Char;
   rec   = record
              a1,a2 :  arr;
           end;
var a  : rec;
   i : Integer;
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
      begin
         a.a1[i]:='a';
         a.a2[i]:='b'
      end;
   i:=4;
   {reading outside 2 arrays in a record}
   c:=a.a1[i];
   c:=a.a2[i];
end.
