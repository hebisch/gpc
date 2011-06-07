program init3a(output);
type ta = array [-3..6] of integer;
     tb = array [boolean] of integer;
     tr = record i : integer; b: boolean; j:integer end;

const ca = ta [-1*(5-2):1; 0,2:0 otherwise 1];
      cb = tb [(1 = 2) or (false > true)..0 = 0 :7];
      cr = tr [i,j: 7; b: false];

var va1 : ta value [-3..-1,1,3..6:1; 0,2:0];
    va2 : ta value [-1*(5-2):1; 0,(1+1):0 ; otherwise 1];
    va3 : ta;
    vb1 : tb;
    vr1 : tr;
    i : integer;
    failure: boolean value false;
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
  vb1 := tb[true: 7 ; false : 0];
  vr1 := tr[j:7;b:true;i:0];
  if (cb[true] <> vb1[vr1.b]) or (cb[cr.b] <> vb1[true]) or (cb[false] <> 7)
       or (vb1[false] <> 0) or (cr.i <> vr1.j) or (cr.j <> 7)
       or (vr1.i <> 0) then begin
    writeln('failed3');
    failure := true
  end;
  if not failure then
    writeln('OK')
end
.
