{$extended-pascal}
program gale7f (output);

type
  t = record
    case integer of
      0: (integer : boolean)  {WRONG}
      otherwise (f : boolean)
    end;

begin
writeln('FAIL');
end.

