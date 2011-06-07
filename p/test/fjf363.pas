{$extended-pascal}

program fjf363 (Output);

var
  f : Text;
  c : Char;
  a : packed array [1 .. 2] of Char;

begin
  Rewrite (f);
  Write (f, 'OK');
  Reset (f);
  Read (f, a);
  Read (f, c);
  if EOF (f) and (c = ' ') then WriteLn (a) else WriteLn ('failed ', EOF (f), ' ', Ord (c))
end.
