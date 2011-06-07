program fsc32;
{actual schema discriminant array read}
uses GPC;
type TIntegers (Size:Integer) = array[1..Size] of Integer;
var t      : ^TIntegers;
   i,j,Res : Integer;

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
   i:=4;
   new (t,i);
   for j:=1 to i do
      t^[j]:=10;
   j:=5;
   {j is out of bounds}
   Res:=t^[j]

end.
