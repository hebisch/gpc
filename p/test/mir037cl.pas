{$gnu-pascal}
program mir037cl;
{conformant array write}
uses GPC;
var v : array['A'..'Z'] of Integer;

procedure  conformantArray(a : array[l..u : Char] of Integer);
begin
   {writing out of lower limits of the conformant array}
   a[Pred(l)]:=10
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
