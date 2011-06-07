{$extended-pascal}
program gale11a (output);

var
  x: record
    f : integer;
    end;
  y: record
    f1: type of x.f;   {WRONG} {x.f is a field-designator which isn't a
variable-identifier or parameter-identifier}
    end;

begin
writeln('FAIL');
end.

