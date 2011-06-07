program az43(output);
(* FLAG --classic-pascal *)
(* The reason, I'm including that option is that there may
   be some dialect implemented by GNU Pascal, which does not
   define the order of evaluation for parameters of "write".
   ISO standards are clear about it *)
var a,b,c,d,x:integer;
    f:text; (* Result is correct if you change that to
    f:file of integer *)
function g(y:integer):integer;
begin
  write(f,x*y);
  x:=x+2;
  g:=x+y;
end;
begin
  rewrite(f);
  x:=1;
  write(f,g(3),g(1));
  reset(f);
  read(f,a,b,c,d);
  if (a=3) and (b=6) and (c=3) and (d=6)
    then writeln('OK')
    else writeln('failed: ',a,b,c,d)
end.
