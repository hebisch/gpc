program mir047d;
{testing [.$[no-]range-checking.] option(s)}
{ FLAG --range-checking }
{      ^^^^^^^^^^^^^^^^ we allow it globally, and test if option in comment bellow works}
type Foo = 'c'..'f';
var a : record fill: Char; a: array [Foo] of Char; end;
    k : Char;

begin
   k := Pred (Low (Foo));
   {$no-range-checking}
   a.a[k] := 'a';
   WriteLn ('OK')
end.
