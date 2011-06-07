program fjf201g;
{$w-}
type t=^cardinal;
procedure p(const x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
