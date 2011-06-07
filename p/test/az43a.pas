{ Variation of az43.pas for `Read'. -- Frank }

program az43a;

type
  PInteger = ^Integer;

var
  a, b: PInteger;
  f: Text;

function g (c: Char; a: PInteger): PInteger;
begin
  Write (c);
  g := a
end;

begin
  New (a);
  New (b);
  Rewrite (f);
  WriteLn (f, 1, ' ', 2);
  Reset (f);
  Read (f, g ('O', a)^, g ('K', b)^);
  if (a^ = 1) and (b^ = 2) then WriteLn else WriteLn ('failed')
end.
