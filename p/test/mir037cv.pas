{$gnu-pascal}
program mir037cv;
{conformant array read}
uses GPC;
var v : array['A'..'Z'] of Integer;
    i : Char;
procedure  conformantArray(a: array[l..u : Char] of Integer);
var j:Integer;
begin
   {reading out of upper limits of the conformant array}
   j:=a[Succ(u)]
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
   for i:='A' to 'Z' do
      v[i]:=20;
   conformantArray(v);
end.
