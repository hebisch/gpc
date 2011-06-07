{$gnu-pascal}
program fsc26;
{conformant array write}
uses GPC;
var v : array[1..100] of Integer;

procedure  conformantArray(a : array[l..u : Integer] of Integer);
begin
   {writing out of upper limits of the conformant array}
   a[u+1]:=10
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
   conformantArray(v);
end.
