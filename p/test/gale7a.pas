{$extended-pascal}
program gale7a (output);

type
  t = record
      boolean : boolean  {WRONG}
    end;

begin
writeln('FAIL');
end.

