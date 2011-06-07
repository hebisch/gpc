{ FLAG -O0 }

program test(output);
label   1;

procedure lvl1;

var
f :text;

procedure lvl2;

begin
goto 1;
halt;
end;

begin
rewrite(f,'file.dat');
writeln(f,'lvl1 called');
lvl2;
halt;
end;

procedure foo;
var
  a: array [1 .. 10000] of Cardinal;
  i: Integer;
begin
  for i := 1 to 10000 do a[i] := $deadbeef
end;

begin
lvl1;
halt;
1:writeln('OK');
foo
end.
