{$extended-pascal}
program gale11 (output);

var
  x: ^ integer;
  y: record
    f1: type of x^;   {WRONG} {x^ is an identified variable  which isn't a
variable-identifier or parameter-identifier}
    end;

begin
writeln('FAIL');
end.

