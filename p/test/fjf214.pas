program fjf214;

type
  PFuncFunc = ^function : PFuncFunc;  { WRONG }

{
function y:pfuncfunc;
begin
  write ('O');
  y:=nil
end;

function x:pfuncfunc;
begin
  x:=@y
end;

procedure p(a:pfuncfunc);
begin
  if a^^=nil then writeln('K')
end;
}

begin
  { p(@x) }
end.
