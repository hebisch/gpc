program fjf70;
type t(a:char)=array['A'..a] of char;

var
  O: t ( 'O' );
  K: t ( 'K' );

procedure p(var v:t);
begin
 with v do write(a)
end;

begin
  p ( O );
  p ( K );
  writeln;
end.
