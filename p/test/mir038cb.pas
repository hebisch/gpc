{$gnu-pascal}
program mir038cb;
{slice array write, what Francois has done for Integer here is for subrange}
uses GPC;
type TCArryInd = 'H'..'P';
var v   : array['A'..'Z'] of Integer;
    i,j : Char;
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
   i:='F'; j:='P';
   {i out of range of bounds type so slice will be out of bounds too}
   conformantArray(v[i..j]);
end.
