{$extended-pascal}
program gale11 (output);

var
  x: array [1..2] of integer;
  y: record
    f1: type of x[1];   {WRONG} {x[1] is an indexed variable which isn't a
variable-identifier or parameter-identifier}
    end;

begin
writeln('FAIL');
end.

