{ FLAG -O -Wall -Werror }

program fjf543d;

procedure foo;
var
  f: file;
  i: LongInt;
  a: Integer = 0;
  b: 0 .. 100 = 0;
  c: Cardinal = 0;
  d: ShortInt = -10;
  e: MedInt = 0;
  g: LongInt = $123456789abcdef0;
begin
  Rewrite (f, 1);
  for i := 1 to 7 do
    begin
      BlockWrite (f, i, SizeOf (i), a);
      if a <> SizeOf (i) then
        begin
          WriteLn ('failed 1');
          Halt
        end
    end;
  Reset (f, 1);
  BlockRead (f, i, 2);
  BlockRead (f, i, 5, a);
  BlockRead (f, i, 6, b);
  BlockRead (f, i, 3, c);
  BlockRead (f, i, 4, d);
  BlockRead (f, i, 8, e);
  BlockRead (f, i, 7, g);
  if (a = 5) and (b = 6) and (c = 3) and (d = 4) and (e = 8) and (g = 7) then
    WriteLn ('OK')
  else
    WriteLn ('failed 2')
end;

begin
  foo
end.
