{$extended-pascal}
program gale7e (output);

type
  t = record
    case integer of
      0: (boolean : boolean)  {WRONG}
      otherwise (f : integer)
    end;

begin
writeln('FAIL');
end.

