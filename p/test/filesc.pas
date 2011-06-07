program filesc(output);
type is(t: boolean) = integer;
     it = is(true);

var fi : file of it;
    var iv : it;
begin
  rewrite(fi);
  iv := 1;
  write(fi, iv, iv, iv);
  reset(fi);
  read(fi, iv);
  if iv <> 1 then writeln('failed');
  read(fi, iv);
  if iv <> 1 then writeln('failed');
  read(fi, iv);
  if iv <> 1 then writeln('failed');
  if eof(fi) then writeln('OK')
end
.
