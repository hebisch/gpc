program fsc34;
{actual schema discriminant const write}
uses GPC;
type TIntegers (Size:Integer) = array[1..Size] of Integer;
var t: TIntegers(3) = (14,15,16);
var    j: Integer;

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
   j:=5;
   {j is out of bounds...}
   t[j]:=10
end.
