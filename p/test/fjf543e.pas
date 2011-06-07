program fjf543e;

procedure foo;
var
  f: file;
  a: Integer;
  b: Char;
begin
  Rewrite (f, 1);
  BlockWrite (f, a, SizeOf (a));
  Reset (f, 1);
  BlockRead (f, a, SizeOf (a), b)  { WRONG }
end;

begin
  WriteLn ('failed')
end.
