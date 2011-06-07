{ BUG: Reading of packed record fields }

program tom5;

var
  r : packed record
    o, k : char;
  end;

begin
  ReadStr ('OK', r.o, r.k);
  WriteLn (r.o, r.k)
end.
