program fjf194a;
type StringPtr = ^string;
var s:^StringPtr;
begin
  New ( s );
  s^:=@'OK';
  writeln(s^^)
end.
