program fjf176b;
{ FLAG -Werror }
begin
  var a:cstring='KO';
  var c1, c2 : char;
  {$x+}
  c1 := (a+1)^;
  c2 := (a)^;
  writeln(c1, c2)
end.
