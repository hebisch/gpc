program fjf590;

type
  t (d: Integer) = record
    f: record
      s: String (2)
    end
  end;

var
  a, b: ^t;

begin
  New (a, -2);
  New (b, 0);
  a^.f.s := 'OK';
  b^.f := a^.f;
  WriteLn (b^.f.s)
end.
