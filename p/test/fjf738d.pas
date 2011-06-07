program fjf738d(output);
begin
  for char in [1 .. 2, 3] do; (* WRONG *)
  writeln('failed')
end.
