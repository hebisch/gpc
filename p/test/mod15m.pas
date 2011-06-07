module m15m;
  export e1 = (x, f);
  var x : integer;
  procedure f(y : integer);
end;
procedure f(y : integer);
begin
  if x = y then
    writeln('OK')
  else
    writeln('failed')
end;
end
.
