{$gnu-pascal}
program fsc27;
{conformant array read}
uses GPC;
var v : array[1..100] of Integer;
   i  : Integer;
procedure  conformantArray(a: array[l..u : Integer] of Integer);
var j:Integer;
begin
   {reading out of upper limits of the conformant array}
   j:=a[u+1]
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
   conformantArray(v);
end.
