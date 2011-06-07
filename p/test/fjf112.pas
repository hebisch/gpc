program fjf112;{OK
}var a:text;b:string(100);
begin
  assign(a,ParamStr (1));
  reset(a);
  seek(a,16);
  readln(a,b);
  writeln(b);
  close(a)
end.
