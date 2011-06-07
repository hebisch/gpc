program fjf144;

type t(a,b:char)=array[b..a] of integer;

procedure p(const v:t);
begin
  writeln(v.a,v.b)
end;

var v:t('O','K');
begin
 p(v) {type mismatch}
end.
