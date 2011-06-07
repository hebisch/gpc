program fjf340c;

procedure foo (var a : array [m .. n : Integer] of Integer);
begin
  if (m = 43) and (n = 44) and (a[m] = 777) and (a[n] = 888)
    then writeln ('OK')
    else writeln ('failed ', m, ' ', n, ' ', a[m], ' ', a[n])
end;

var
  a : array [42 .. 45] of Integer = (666, 777, 888, 999);

begin
  foo (a[43 .. 44])
end.
