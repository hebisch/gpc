program fjf201e;
{$w-}
type t=^cardinal;
procedure p(var x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
