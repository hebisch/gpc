program fjf106;
begin
  var f:text;
  var s:string(42);
  assign(f,ParamStr (1));
  reset(f);
  readln(f,s);
  close(f);
  if s.capacity=42 then writeln('OK') else writeln('Failed: ',s.capacity)
end.
