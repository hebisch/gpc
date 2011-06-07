program fjf979;

type
  a = record
  case Char of
    'a': (b: Integer)
  end;

var
  p: ^a;

begin
  New (p, Ord ('a'))  { WRONG }
end.
