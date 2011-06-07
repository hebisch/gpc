program test(output);

var i : Integer;

begin
    i := i + 1;  { WARN }
    writeln('failed: ', i);
end.
