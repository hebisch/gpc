program fjf350;

type
  f_oo = string (2);

var
  a : ^f_oo;

begin
  new (a);
  a^ := 'OK';
  writeln (a^)
end.
