program fjf39;
var a:array[1..10] of char='';
var O, K: integer;
begin
  O:= ord(a[1]);
  a:='';
  K:= ord(a[1]);
  if O = K then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', O, ' ', K );
end.
