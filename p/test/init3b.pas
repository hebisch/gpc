program init3b(output);
type ta = array [-3..6] of integer;
     tr = record i : integer; b: boolean; j:integer end;
     tb = array [boolean] of tr;

const ca = ta [1;1;1;0;1;0;1;1;1;1];
      cb = tb [otherwise (7,true,0)];
      cr = tr [b: false; 7;i:7];

var va1 : ta value (-3..-1:1, 1:1, 3:1, 1, 1, 1, 0:0, 2:0);
    va2 : ta = [-1*(5-2):1; 0,(1+1):0 ; otherwise 1];
    va3 : ta;
    vb1 : tb value ([7;true;0];[7;true;0]);
    vb2 : tb;
    vr1 : tr;
    i : integer;
    failure: boolean value false;

function cmpr(r1, r2: tr) : boolean;
begin
  cmpr := (r1.i <> r2.i) or (r1.j <> r2.j) or (r1.b <> r2.b)
end;

function cmpt(t1, t2: tb) : boolean;
begin
  cmpt := cmpr(t1[false], t2[false]) or cmpr(t1[true], t2[false])
end;

begin
  va3 := ta[otherwise 1];
  va3[ca[2]] := 0;
  va3[2] := 0;
  for i := -3 to 6 do begin
    if (ca[i] <> va1[i]) or (va1[i] <> va2[i]) or (va2[i] <> va3[i]) then begin
      writeln('failed1: ', i);
      failure := true
    end
  end;
  if (va1[-3] <> 1) or (va1[-1] <> 1) or (va1[-1] <> 1) or (va1[0] <> 0)
       or (va1[1] <> 1) or (va1[2] <> 0) or (va1[3] <> 1) or (va1[4] <> 1)
       or (va1[5] <> 1) or (va1[6] <> 1) then begin
    writeln('failed2');
    failure := true
  end;
  vb2 := tb[true: (7;j:0;b:true) ; false : (7,true;7)];
  vr1 := tr[j:0;b:true;i:7];
  if cmpt(cb, vb1) then begin
    writeln('failed3');
    failure := true
  end;
  if cmpr(vb2[true], vb1[true]) or cmpr(vb1[false], vb1[true]) or
      cmpr(vr1, vb1[false]) then begin
    writeln('failed4');
    failure := true
  end;
  if (vb2[false].i <> 7) or (vb2[false].j <> 7) or not vb2[false].b
      or (vr1.i <> 7) or (vr1.j <> 0) or not vr1.b
      or (cr.i <> 7) or (cr.j <> 7) or cr.b then begin
    writeln('failed5');
    failure := true
  end;
  if not failure then
    writeln('OK')
end
.
