program fjf145;
var
  a:file;
  b:array[1..3] of char='xOK';
  c:array[1..2] of char;
begin
  rewrite(a,1);
  blockwrite(a,b,3);
  reset(a,1);
  seek(a,1);
  blockread(a,c,2);
  writeln(c)
end.
