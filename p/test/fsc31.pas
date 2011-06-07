program fsc31;
{actual schema discriminant array write}
uses GPC;
type TIntegers (Size:Integer) = array[1..Size] of Integer;
var t : ^TIntegers;
   i,j  : Integer;

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
   New (t,i);
   j:=5;
   {j is out of bounds}
   t^[j]:=4;
end.
