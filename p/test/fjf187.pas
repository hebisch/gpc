program fjf187; {Should output OK}
var
  f:text;
  s:string(100);

procedure p(const s:string);
begin
  if s = '' then
    begin
      writeln ('failed 1');
      halt
    end;
  reset(f,s)
end;

begin
  p(ParamStr (1));
  readln(f,s);
  writeln(s[Pos('output',s)+7..Pos('}',s)-1])
end.
