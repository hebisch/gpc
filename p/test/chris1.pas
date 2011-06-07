program Bug;
type tVect=record
                x,y,z:real;
             end;
operator + (a,b:tVect) r:tVect;
begin
  r.x:=a.x+b.x;
  r.y:=a.y+b.y;
  r.z:=a.z+b.z;
end;  {BTW - here it warns "return value not assigned"}

type tNotOK=array[1..5] of tVect;
     {tIsOk=array[1..5] of record p:tVect end;}

var a,b:tVect;
    prob:tNotOK;
    r:tVect;
begin
  r:=a+b; {works fine}
  r:=b+prob[1]; {doesn't :-(}
  a:=prob[1];r:=a+b;     {Does}
  writeln ( 'OK' );
end.
