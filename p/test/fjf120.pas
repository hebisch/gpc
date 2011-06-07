program fjf120;

var
  a:text;
  b:file of char;
  f:boolean;
  s:String (2);

begin
  assign(a,'-');
  reset(a);
  reset(b,'-');
  f:=(filepos(input)=0) and (filepos(a)=0) and (filepos(b)=0);
  readln(a,s);
  if f
    then writeln(s)
    else writeln('Failed: ',filepos(input),', ',filepos(a),', ',filepos(b))
end.
