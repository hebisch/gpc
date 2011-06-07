unit Cagliostro1u;
interface
implementation
var pro:array[0..1] of ^procedure;
    k:integer;
{*******************************}
procedure MC;
begin
{ writeln(' Merry Christmas ! '); }
  writeln ( 'OK' );
end;
{*******************************}
begin
for k:=0 to 1 do pro[k]:=@MC;
pro[0]^;
end.
