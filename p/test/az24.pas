program az24(output);
begin
  if 1.1 in [] then; (* WRONG - real is not an ordinal type *)
  writeln('failed')
end.
