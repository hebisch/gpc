program fjf933a;

type
  a (b: Integer) = record
  case 0 .. 0 of
    0: (case Boolean of
        False: (c: Integer);
        True:  (d: Integer))
  end;

var
  v: a (42);

begin
  with v do
    begin
      c := Ord ('O');
      Write (Chr (c));
      d := Ord ('K');
      WriteLn (Chr (d))
    end
end.
