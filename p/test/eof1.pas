program test;
var
  f : file of char;
  c : char;
begin
  rewrite(f,'test.dat');
  seek(f,0);
  f^:='x'; (*GIVES ERROR HERE*)
  put(f);
  close(f);
  reset(f);
  read(f,c);
  if c='x' then WriteLn ('OK') else WriteLn ('failed')
end.
