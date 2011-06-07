{$extended-pascal}
program gale9a (output);
const
  c = 2;

var
  y : type of c;   {WRONG} {c is neither a variable-identifier or a parameter-identifier}

begin
writeln('FAIL');
end.

