program gale8r (output);

type
  t = integer;
  foo = function (t: t) : integer;  { WARN }


begin
writeln('FAIL');
end.

