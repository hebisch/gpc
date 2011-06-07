{$extended-pascal}
program gale7i (output);

type
  t(integer : boolean) = record
    i : integer { WRONG }
    end;

begin
writeln('FAIL');
end.

