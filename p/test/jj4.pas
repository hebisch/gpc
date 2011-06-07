program ArrayTest(output);

type
  node = 0..4500;
  A = array[node] of integer;

var
  N1 : A;
  N2 : ^A;

begin
  N2:= @N1;
  writeln('OK');
end.
