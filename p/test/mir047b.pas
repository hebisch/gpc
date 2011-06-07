program mir047b;
{testing --[no-]range-checking command-line option(s)}
{ FLAG --no-range-checking }
uses GPC;

type Foo = 'c'..'f';
var a : record fill: Char; a: array [Foo] of Char; end;
    k : Char;

procedure DontExpectError;
begin
  if ExitCode <> 0 then
    begin
      WriteLn ('failed');
      Halt (0) {!}
    end
  else
    WriteLn ('OK')
end;

begin
   AtExit(DontExpectError);
   k := Pred (Low (Foo));
   a.a[k] := 'a';
end.
