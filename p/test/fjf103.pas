program fjf103;

procedure fillchar(a,b:integer;c:byte);
begin
end;

var a:integer;
begin
  FillChar(a,sizeof(a),1000); { WRONG }
  writeln('Failed')
end.
