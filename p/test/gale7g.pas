{$extended-pascal}
program gale7g (output);

type
  t = record
    case boolean : integer of
      0: (b : boolean)  {WRONG}
      otherwise (f : integer)
    end;

begin
writeln('FAIL');
end.

