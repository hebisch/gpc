program fjf186; {Should output OK}
var
  f:text;
  s:string(100);
  n:string(520)=ParamStr (1);  { Idea how to solve this: let init_any() }
begin                         { generate code to do the initialization }
  if n = '' then
    begin
      writeln ('failed 1');
      halt
    end;
  reset(f,n);
  readln(f,s);
  writeln(s[Pos('output',s)+7..Pos('}',s)-1])
end.
