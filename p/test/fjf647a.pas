program fjf647a;

type
  t = (a, b, c, d, e);

function f: Boolean;
begin
  f := True
end;

function g: t;
begin
  g := d
end;

begin
  WriteLn (Succ ('N', Ord (f)), Pred ('N', Ord (g)));
end.
