program fjf321a;

type
  a = record
  case integer of
    1 :  (foo : integer);
    else (bar : integer)
  end;

begin
  writeln ('OK')
end.
