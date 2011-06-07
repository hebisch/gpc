program fjf259;

type
  t = record
  case boolean of
    false : (a : integer);
    true  : (s : string (2));
  end;

const
  v : t = (s : 'OK');

begin
  writeln (v.s)
end.
