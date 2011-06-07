{$extended-pascal}
program gale7d (output);

type
  t = record
    b : boolean;
    case integer of
      0: (boolean : integer)  {WRONG}
      otherwise (f : integer)
    end;

begin
writeln('FAIL');
end.

