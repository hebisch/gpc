program fjf828b;

type
  t = record
    i: Integer
  end;

operator foo (a, b: t) = c: t;
begin
  c.i := a.i + b.i
end;

var
  a, b: restricted t;
  c: t;

begin
  c := a foo b  { WRONG (restricted) }
end.
