program fjf584a;

type
  Foo = ^Foo;
  Bar = ^Bar;

var
  x, z: Foo;
  y: Bar;

begin
  if SizeOf (Foo) <> SizeOf (Pointer) then begin WriteLn ('failed 1'); Halt end;
  if SizeOf (Bar) <> SizeOf (Pointer) then begin WriteLn ('failed 2'); Halt end;
  if SizeOf (x) <> SizeOf (Pointer) then begin WriteLn ('failed 3'); Halt end;
  if SizeOf (y) <> SizeOf (Pointer) then begin WriteLn ('failed 4'); Halt end;
  x := @z;
  x^ := x;
  if z <> @z then begin WriteLn ('failed 5'); Halt end;
  if z^ <> z then begin WriteLn ('failed 6'); Halt end;
  z := @x;
  x := x^;
  if x <> @x then begin WriteLn ('failed 7'); Halt end;
  if x^ <> x then begin WriteLn ('failed 8'); Halt end;
  New (x);
  New (x^);
  z := x^;
  Dispose (z);
  WriteLn ('OK')
end.
