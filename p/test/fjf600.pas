program fjf600;

type
  t1 (d: Integer) = record
    a: Integer;
  case Boolean of
    False: (b: array [1 .. d] of Integer);
    True:  (c: array [1 .. d] of Integer);
  end;

  t2 (d: Integer) = record
    a: Integer;
    b: record
         d: array [1 .. 8] of Byte;
       case e: Integer of
         0: (b: array [1 .. d] of Integer);
         1: (c: array [1 .. d] of Integer);
       {$W-}
       end;
       {$W+}
  end;

  t3 (d: Integer) = record
    a: Integer;
  case Integer of
    0: (b: array [1 .. d, 1 .. 5] of Integer);
    1: (c: array [1 .. d, 1 .. d] of Integer);
  end;

  t4 (d: Integer) = record
    a: Integer;
  case Integer of
    0: (b: array [1 .. d, 1 .. 5] of Integer);
    1: (c: array [1 .. d, 1 .. d] of array [-3 .. 4] of Char);
  end;

var
  p1: ^t1;
  p2: ^t2;
  p3: ^t3;
  p4: ^t4;
  i, j: Integer;
  OK: Boolean = True;

procedure Check (n, a, b: Integer);
begin
  if a <> b then
    begin
      WriteLn ('failed ', n, ' ', i, ' ', a, ' ', b);
      OK := False
    end
end;

begin
  for i := 1 to 42 do
    begin
      New (p1, i); Check (1, SizeOf (p1^), (2 + i) * SizeOf (Integer));
      New (p2, i); Check (2, SizeOf (p2^), (3 + i) * SizeOf (Integer) + 8);
      New (p3, i); Check (3, SizeOf (p3^), (2 + Max (5, i) * i) * SizeOf (Integer));
      New (p4, i); Check (4, SizeOf (p4^), 2 * SizeOf (Integer) + Max (5 * i * SizeOf (Integer), Sqr (i) * 8));
      for j := 1 to i do p1^.b[j] := Sqr (99 - j);
      for j := 1 to i do
        if p1^.c[j] <> Sqr (99 - j) then
          begin
            WriteLn ('failed 5 ', j, ' ', p1^.c[j], ' ', Sqr (99 - j));
            OK := False
          end
    end;
  if OK then WriteLn ('OK')
end.
