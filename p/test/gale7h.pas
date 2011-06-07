{$extended-pascal}
program gale7h (output);

type
  t = record
    boolean : record b : boolean end {WRONG}
    end;

begin
writeln('FAIL');
end.

