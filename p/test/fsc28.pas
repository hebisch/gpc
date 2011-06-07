{$gnu-pascal}
program fsc28;
{slice array write}
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
   i:=99; j:=110;
   {j out of bounds so slice will be out of bounds too (write)}
   conformantArray(v[i..j]);
end.
