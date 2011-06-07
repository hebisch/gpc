program fjf413h1;

type
  a = String (2);

type
  foo = ^a;

var
  w : a = 'OK';
  v : foo = @w;

begin
  WriteLn (v^)
end.
