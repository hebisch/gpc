program fjf1050c (Output);

type
  a (n: Integer) = String (n);

var
  s: a (2);

begin
  s := 'K';
  WriteLn (Concat ('', '', '', 'O', s))
end.
