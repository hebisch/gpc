program fjf915mm;

type
  t (n: Integer) = Integer;

var
  a: ^t;

begin
  Dispose (a, and_then (2))  { WRONG }
end.
