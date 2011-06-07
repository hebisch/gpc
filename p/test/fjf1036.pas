program fjf1036 (Output);

function f: Char;
begin
  Write ('f');
  f := 'F'
end;

function g: Integer;
begin
  Write ('g', f, f, 'G');
  g := 2
end;

begin
  WriteLn ('a', f, 'b', f, 'c', g, 'd', 'e' : g, 'f', 0.0 : 0 : g, 'h')
end.
