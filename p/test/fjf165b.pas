program fjf165b;

{$w-,borland-pascal}

const n=6;

type t=array[1..n] of char;

const
  c:t=('a','B','�','�','�','-');
  u:t=('A','B','�','�','�','-');

var
  i:1..n;

begin
  for i:=1 to n do
    if UpCase(c[i])<>u[i] then
      begin
        WriteLn ('Failed: ', UpCase(c[i]), u[i]);
        Halt (1)
      end;
  WriteLn ('OK')
end.
