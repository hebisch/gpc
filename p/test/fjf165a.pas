{ COMPILE-CMD: fjf165a.cmp }

program fjf165a;

const n=6;

type t=array[1..n] of char;

var
  i:1..n;
  c:t=('a','B','�','�','�','-');   { Only with German locale }
  u:t=('A','B','�','�','�','-');
  l:t=('a','b','�','�','�','-');

begin
  for i:=1 to n do
    if (UpCase(c[i])<>u[i]) or (LoCase(c[i])<>l[i]) then
      begin
        WriteLn ('Failed: ', UpCase(c[i]), u[i], LoCase(c[i]), l[i]);
        Halt (1)
      end;
  WriteLn ('OK')
end.
