program test(output);

function trash(n: integer):integer;
begin
  if n>0 then
    trash := (2*trash(n-1)+1) mod 997
  else
    trash := 15
end;

procedure lvl1;
label 1;

begin
  begin
  var f :text;
  rewrite(f,'file.dat');
  writeln(f,'lvl1 called');
  begin
    writeln('lvl2 executing');
    goto 1;
  end;
  end;
1:
end;

begin
writeln('lvl0 called');
lvl1;
writeln('trash = ', trash(10000));
writeln('it worked');
end.
