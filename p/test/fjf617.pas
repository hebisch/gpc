program fjf617;

var
  a0: Integer = 42;
  a1: Integer = (43);
  a2: Integer = ((44));
  a3: Integer = (((45)));
  a4: Integer = ((((46))));
  a5: Integer = (((((47)))));
  a6: Integer = ((((((48))))));
  b1: array [1 .. 1] of Integer = (53);
  b2: array [1 .. 1] of Integer = ((54));
  b3: array [1 .. 1] of Integer = (((55)));
  b4: array [1 .. 1] of Integer = ((((56))));
  b5: array [1 .. 1] of Integer = (((((57)))));
  b6: array [1 .. 1] of Integer = ((((((58))))));
  c2: array [1 .. 1, 1 .. 1] of Integer = ((64));
  c3: array [1 .. 1, 1 .. 1] of Integer = (((65)));
  c4: array [1 .. 1, 1 .. 1] of Integer = ((((66))));
  c5: array [1 .. 1, 1 .. 1] of Integer = (((((67)))));
  c6: array [1 .. 1, 1 .. 1] of Integer = ((((((68))))));
  d3: array [1 .. 1, 1 .. 1, 1 .. 1] of Integer = (((75)));
  d4: array [1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((76))));
  d5: array [1 .. 1, 1 .. 1, 1 .. 1] of Integer = (((((77)))));
  d6: array [1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((((78))))));
  e4: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((86))));
  e5: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = (((((87)))));
  e6: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((((88))))));
  f5: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = (((((97)))));
  f6: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((((98))))));
  g6: array [1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1, 1 .. 1] of Integer = ((((((22))))));
  h: array [2 .. 2, 3 .. 4, 5 .. 5, 6 .. 7] of Integer =
    (((((3),((5)))),((((((6)))),(((((7)))))))));
  OK: Boolean = True;
  n: Integer = 0;

procedure Check (a, b: Integer);
begin
  Inc (n);
  if a <> b then
    begin
      WriteLn ('failed ', n, ' ', a, ' ', b);
      OK := False
    end
end;

begin
  Check (a0, 42);
  Check (a1, 43);
  Check (a2, 44);
  Check (a3, 45);
  Check (a4, 46);
  Check (a5, 47);
  Check (a6, 48);
  Check (b1[1], 53);
  Check (b2[1], 54);
  Check (b3[1], 55);
  Check (b4[1], 56);
  Check (b5[1], 57);
  Check (b6[1], 58);
  Check (c2[1, 1], 64);
  Check (c3[1, 1], 65);
  Check (c4[1, 1], 66);
  Check (c5[1, 1], 67);
  Check (c6[1, 1], 68);
  Check (d3[1, 1, 1], 75);
  Check (d4[1, 1, 1], 76);
  Check (d5[1, 1, 1], 77);
  Check (d6[1, 1, 1], 78);
  Check (e4[1, 1, 1, 1], 86);
  Check (e5[1, 1, 1, 1], 87);
  Check (e6[1, 1, 1, 1], 88);
  Check (f5[1, 1, 1, 1, 1], 97);
  Check (f6[1, 1, 1, 1, 1], 98);
  Check (g6[1, 1, 1, 1, 1, 1], 22);
  Check (h[2, 3, 5, 6], 3);
  Check (h[2, 3, 5, 7], 5);
  Check (h[2, 4, 5, 6], 6);
  Check (h[2, 4, 5, 7], 7);
  if OK then WriteLn ('OK')
end.
