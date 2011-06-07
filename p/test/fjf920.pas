program fjf920;

type
  t = String (10);

var
  p: ^t;

begin
  New (p);
  p^ := 'OK';
  WriteLn (p^)
end.
