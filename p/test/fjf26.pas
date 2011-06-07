program fjf26;
var
  x : array [-6 .. 42] of Char;
  i : Integer;
begin
  x := 'xxfailed';
  x := 'OK';
  i := High (x);
  while x [i] = ' ' do Dec (i);
  writeln (x [Low (x) .. i])
end.
