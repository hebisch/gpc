program fjf862;

type
  a = procedure;
  b = ^procedure;
  c = function: Integer;
  d = ^function: Integer;

var
  v: a;
  w: b;
  x: c;
  y: d;

procedure p1; begin WriteLn ('p1') end;
procedure p2; begin WriteLn ('p2') end;
procedure p3; begin WriteLn ('p3') end;
procedure p4; begin WriteLn ('p4') end;
procedure p5; begin WriteLn ('p5') end;
procedure p6; begin WriteLn ('p6') end;
procedure p7; begin WriteLn ('p7') end;
procedure p8; begin WriteLn ('p8') end;
procedure p9; begin WriteLn ('p9') end;
procedure q1 (procedure p); begin Write ('q1 '); p  end;
procedure q2 (p: a);        begin Write ('q2 '); p  end;
procedure q3 (p: b);        begin Write ('q3 '); p^ end;

function f1: Integer; begin f1 := 1 end;
function f2: Integer; begin f2 := 2 end;
function f3: Integer; begin f3 := 3 end;
function f4: Integer; begin f4 := 4 end;
function f5: Integer; begin f5 := 5 end;
function f6: Integer; begin f6 := 6 end;
function f7: Integer; begin f7 := 7 end;
function f8: Integer; begin f8 := 8 end;
function f9: Integer; begin f9 := 9 end;
procedure r1 (function f: Integer); begin WriteLn ('r1 ', f)  end;
procedure r2 (f: c);                begin WriteLn ('r2 ', f)  end;
procedure r3 (f: d);                begin WriteLn ('r3 ', f^) end;
procedure s  (i: Integer);          begin WriteLn ('s  ', i)  end;

begin
  p1;
  q1 (p2);
  q2 (p3);
  q3 (@p4);
  v := p5;
  v;
  w := @p6;
  w^;
  {$local W-} @v := @p7; {$endlocal}
  v;
  w := Addr (p8);
  w^;
  {$local W-} @v := Addr (p9); {$endlocal}
  v;
  WriteLn (Assigned (@p9));
  WriteLn (Assigned (@v));
  WriteLn (Assigned (v));
  WriteLn (Assigned (w));

  WriteLn (f1);
  r1 (f2);
  s (f2);
  r2 (f3);
  s (f3);
  r3 (@f4);
  s (f4);
  x := f5;
  WriteLn (x);
  y := @f6;
  WriteLn (y^);
  {$local W-} @x := @f7; {$endlocal}
  WriteLn (x);
  y := Addr (f8);
  WriteLn (y^);
  {$local W-} @x := Addr (f9); {$endlocal}
  WriteLn (x);
  WriteLn (Assigned (@f9));
  WriteLn (Assigned (@x));
  WriteLn (Assigned (x));
  WriteLn (Assigned (y));
end.
