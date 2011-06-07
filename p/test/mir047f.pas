program mir047f;
{testing [.$R[+-].] option(s)}
{ FLAG --range-checking }
{      ^^^^^^^^^^^^^^^^ we allow it globally, and test if option in comment bellow works}
type Foo = 'c'..'f';
var a : record fill: Char; a: array [Foo] of Char; end;
    k : Char;

begin
   k := Pred (Low (Foo));
   {$R-}
   a.a[k] := 'a';
   WriteLn ('OK')
end.
