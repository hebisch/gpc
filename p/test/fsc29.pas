{$gnu-pascal}
program fsc29;
{slice array 2}
uses GPC;
var v  : array[1..100] of Integer;
   i,j : Integer;
procedure  conformantArray(a: array[l..u : Integer] of Integer);
begin
end;

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
   for i:=1 to 100 do
      v[i]:=20;
   i:=99; j:=90;
   {i > j}
   conformantArray(v[i..j]);
end.
