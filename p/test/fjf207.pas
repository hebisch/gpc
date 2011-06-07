program fjf207;
const c:array[1..2] of char='OK';
var
  a:file;
  b:array[1..sizeof(file)] of byte absolute a;
  d:array[1..2] of char;
begin
  rewrite(a,1);
  blockwrite(a,c,sizeof(c));
  reset(file(b),1);
  blockread(a,d,sizeof(d));
  writeln(d);
end.
