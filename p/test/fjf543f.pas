{ FLAG -D__BP_TYPE_SIZES__ }

program fjf543f;

uses System;

procedure foo;
var
  f: file;
  a, b: Integer;
  c: Cardinal;
begin
  Rewrite (f, 1);
  for a := 1 to 2 do BlockWrite (f, a, SizeOf (a));
  Reset (f, 1);
  BlockRead (f, a, SizeOf (a), b);
  BlockRead (f, a, SizeOf (a), c);
  if (b = SizeOf (a)) and (c = SizeOf (a)) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end;

begin
  foo
end.
