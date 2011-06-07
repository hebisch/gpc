program fjf126;

var testnr:integer=0;

procedure test(x,y:boolean);
begin
  inc(testnr);
  if x<>y then
    begin
      writeln('Failed ',testnr);
      halt
    end
end;

var
  a:text;
  b:file;
  y:array[1..100] of char;
begin
  rewrite(a,'eof.dat');close(a);
  rewrite(a,'ten.dat');write(a,'1234567890');close(a);
  reset(a,'ten.dat');test(eof(a),false);
  reset(a,'eof.dat');test(eof(a),true);
  reset(b,'ten.dat',1);test(eof(b),false);
  blockread(b,y,9);test(eof(b),false);
  blockread(b,y,1);test(eof(b),true);
  reset(b,'eof.dat',1);test(eof(b),true);
  reset(b,'-',1);test(eof(b),false);
  blockread(b,y,1);
  test(eof(b),false);
  blockread(b,y,0);
  test(eof(b),false);
  blockread(b,y[2],1);
  test(eof(b),true);
  writeln(y[1],y[2])
end.
