program init3d(output);
type tvc = 0..2;
     tvr1 = record i : integer; case tvc of
              0:    (j : integer);
              1..2: (c: char; k: integer)
            end value [i: 666; case 1 of [c: 'c'; k : 7]];
     tvr2 = record i : integer; case s : tvc of
              0:    (j : integer);
              otherwise (c: char; k: integer)
            end;
function cmpr(var r1 : tvr1; var r2 : tvr2): boolean;
  var res: boolean;
begin
  res := r1.i <> r2.i;
  case r2.s of
       0: res := res or (r1.j <> r2.j);
    1..2: res := res or (r1.c <> r2.c) or (r1.k <> r2.k)
  end;
  cmpr := res;
end;

var vr1 : tvr1 = (i: 666; c: 'c'; k : 7);
    vr2 : tvr2 = (i: 666; s:1; c: 'c'; k : 7);
    ok : boolean value true;
begin
  if cmpr(vr1, vr2) then begin
    writeln('failed1');
    ok := false
  end;
  if (vr2.s <>1) or (vr2.i <> 666) or (vr2.c <> 'c') or (vr2.k <> 7) then begin
    writeln('failed2');
    ok := false
  end;
  if ok then writeln('OK')
end
.
