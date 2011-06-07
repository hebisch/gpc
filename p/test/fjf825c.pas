program fjf825c;

type
  _i = Integer;

operator foo (a, b: _i) c: _i; forward;  { WRONG (unresolved forward) }

function Foo__i__i (a, b: _i) = c: _i;
begin
  c := a + b
end;

begin
end.
