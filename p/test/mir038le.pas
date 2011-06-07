{$gnu-pascal}
program mir038le;
{slice array write, what Francois has done for Integer here is for subrange}
uses GPC;
type TCArryInd = 200000000012..200000000042;
var v   : array[200000000001..200000000100] of Integer;
    i,j : LongInt;
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
   i:=200000000001; j:=200000000099;
   { i < lower, j > upper }
   conformantArray(v[i..j]);
end.
