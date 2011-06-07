program mir047c;
{testing [.$[no-]range-checking.] option(s)}
{ FLAG --no-range-checking }
{      ^^^^^^^^^^^^^^^^^^^ we ban it globally, and test if option in comment bellow works}
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
   {$range-checking}
   a[k] := 'a';
end.
