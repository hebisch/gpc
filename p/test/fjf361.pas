{ FLAG -Werror }

program fjf361;
var a : array [0 .. 0] of String (2);
begin
  a (.2#0.) := 'OK';
  WriteLn (a (.$0.))
end.
