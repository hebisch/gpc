{$extended-pascal}
program gale10 (output);

var
  y: type of 3.14;  {WRONG} {3.14 isn't an identifier at all let alone
being either a variable-identifier or a parameter-identifier}

begin
writeln('FAIL');
end.

