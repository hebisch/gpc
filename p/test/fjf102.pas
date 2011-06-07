program fjf102;
var a:integer;
begin
  FillChar(a,sizeof(a),1000); { WRONG }
  writeln('Failed')
end.
