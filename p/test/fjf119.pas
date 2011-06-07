program fjf119;

var
  f:boolean;
  s:String(2);

begin
  f:=filepos(input)=0;
  readln(s);
  if f
    then writeln(s)
    else writeln('Failed: ',filepos(input))
end.
