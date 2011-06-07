{$extended-pascal}
program gale11 (output);

function x : integer;
begin
  x := 1
end;
var
  y: record
    f1: type of x;   {WRONG} {x is an integer expression which isn't a
variable-identifier or parameter-identifier}
    end;

begin
writeln('FAIL');
end.

