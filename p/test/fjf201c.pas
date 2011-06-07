program fjf201c;
{$w-}
type t=^cardinal;
procedure p(x:t);
begin
  WriteLn('Failed')
end;
var a:^integer;
begin
  p(a) { WRONG }
end.
