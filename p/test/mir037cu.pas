{$gnu-pascal}
program mir037cu;
{conformant array write}
uses GPC;
var v : array['A'..'Z'] of Integer;

procedure  conformantArray(a : array[l..u : Char] of Integer);
begin
   {writing out of upper limits of the conformant array}
   a[Succ(u)]:=10
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
