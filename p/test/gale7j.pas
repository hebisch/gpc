{$extended-pascal}
program gale7j (output);

type
  t(integer : boolean) = record
    integer : char { WRONG }
    end;

begin
writeln('FAIL');
end.

