program gale8r (output);

type
  t = integer;
  foo = procedure (function f(t: integer) = t : integer);  { WARN }


begin
writeln('FAIL');
end.

