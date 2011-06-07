{$gnu-pascal}
program mir038ie;
{slice array write, what Francois has done for Integer here is for subrange}
uses GPC;
type TCArryInd = 12..42;
var v   : array[1..100] of Integer;
    i,j : Integer;
procedure  conformantArray(a: array[l..u : TCArryInd] of Integer);
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
   i:=1; j:=99;
   {i < lower, j > upper}
   conformantArray(v[i..j]);
end.
