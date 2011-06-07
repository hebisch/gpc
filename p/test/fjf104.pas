program fjf104;

var
  f:file of shortint;
  a,b:shortint;

procedure test(pos,size,nr:integer);
begin
  if (filepos(f)<>pos) or (filesize(f)<>size) then
    begin
      writeln('Failed ',nr,' (',filepos(f),',',filesize(f),')');
      halt
    end
end;

begin
  assign(f,'tmp.dat');
  rewrite(f);
  test(0,0,0);
  write(f,ord('O'),ord('K'),42,666);
  test(4,4,1);
  seekwrite(f,1);
  test(1,4,2);
  definesize(f,3);
  test(1,3,3);
  seek(f,2);
  test(2,3,4);
  truncate(f);
  test(2,2,5);
  reset(f);
  test(0,2,6);
  read(f,a,b);
  test(2,2,7);
  close(f);
  writeln(chr(a),chr(b))
end.
