program fjf127;
var
  f:file of integer;
  a,b:integer;
begin
  rewrite(f);
  write(f,ord('O'),ord('K'),0);
  reset(f);
  if eof(f) then begin writeln('Failed'); halt end;
  read(f,a,b);
  close(f);
  writeln(chr(a),chr(b))
end.
