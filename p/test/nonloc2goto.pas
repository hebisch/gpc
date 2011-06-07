program test(output);
label 1;

procedure trash(n: integer);
begin
  if n>0 then trash(n-1)
end;

procedure lvl1;

var
dd : array [1..20] of char;
f :text;

procedure lvl2;
begin
goto 1;
end;

begin
rewrite(f,'file.dat');
writeln(f,'lvl1 called');
lvl2;
end;

begin
lvl1;
1:
trash(10000);
writeln('OK');
end.
