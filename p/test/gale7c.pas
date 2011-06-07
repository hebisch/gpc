{$extended-pascal}
program gale7c (output);

type
  t = record
    boolean : integer;
    b : boolean {WRONG}
    end;

begin
writeln('FAIL');
end.

