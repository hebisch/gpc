program fjf543c;

procedure foo;
const b: Cardinal = 0;
var
  f: file;
  a: Integer;
begin
  Rewrite (f, 1);
  BlockWrite (f, a, SizeOf (a));
  Reset (f, 1);
  BlockRead (f, a, SizeOf (a), b)  { WARN }
end;

begin
  WriteLn ('failed')
end.
