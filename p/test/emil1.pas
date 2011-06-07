program emil1;

var
  t : packed array[0..1]of 0..32768;  {non-packed is OK, <=32767 is OK}
  h : 0..1;  {or integer or whatever}

begin
  t[0]:=2;
  t[1]:=3;
  h:=0;
  t[h]:=0;    {t[0]:=0 is OK}
  if (t[0]=0) and (t[1]=3) then WriteLn ('OK') else WriteLn ('failed')
end.
