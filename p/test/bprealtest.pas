program Foo;

uses System;

type
  RBR = packed record
    r : Real;
    BR : BPReal
  end;

var
  i : Integer;
  x : RBR;
  r: BPReal;
  R2 : Real;
  f : file of RBR;

begin
  Rewrite (f, 'bpreal.dat');
  Randomize;
  for i := 1 to 20000 do
    begin
      x.r := (Random + 1e-6) * Exp (Random (86) - 43);
      if Random (2) = 0 then x.r := -x.r;
      x.BR := RealToBPReal (x.r);
      Write (f, x);
      r := x.BR;
      R2 := BPRealToReal (r);
      if Abs (x.r / R2 - 1) > 1e-6 then
        begin
          WriteLn ('failed: ', i, ' ', x.r, ', ', R2);
          Halt (1)
        end
    end;
  WriteLn ('OK')
end.
