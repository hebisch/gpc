program fsc06;
{packed array write}
uses GPC;
{assigning an Integer after the end of the packed array}
var t : packed array[1..2] of Integer;
   i  : Integer;

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
   i:=3;
   {Write outside range of _packed_ array, one too far... Same as fsc01.pas}
   t[i]:=10;
end.
