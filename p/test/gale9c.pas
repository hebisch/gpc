{$extended-pascal}
program gale9a (output);
type en = (a, b, c, d);

var
  y : type of c;   {WRONG} {c is neither a variable-identifier or a parameter-identifier}

begin
writeln('FAIL');
end.

