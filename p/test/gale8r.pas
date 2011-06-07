program gale8r (output);

type
  t = integer;
  foo = procedure (t: t);  { WARN }


begin
writeln('FAIL');
end.

