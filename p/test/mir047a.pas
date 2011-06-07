program mir047a;
{testing --[no-]range-checking command-line option(s)}
{ FLAG --range-checking }
uses GPC;

type Foo = 'c'..'f';
var a : array [Foo] of Char;
    k : Char;

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
   k := Pred (Low (Foo));
   a[k] := 'a';
end.
