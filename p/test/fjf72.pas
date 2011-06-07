program fjf72;
type pint=^Integer;
var foo: array [ 1..2 ] of Integer;
    a:Integer absolute foo [ 1 ];
    b:Integer absolute foo [ 2 ];
begin
  b:=1;
{$x+}
  Dec((pint(@a)+1)^);
  Dec(Succ(pint(@a))^);
  Dec(Succ(pint(@a),1)^);
  Dec(Pred(Succ(pint(@a),2))^);
  Dec((Succ(pint(@a),11)-10)^);
  Dec(Succ(pint(@a)-12,13)^);
  Dec(Succ(Pred(pint(@a),2),3)^);
  if b=-6 then writeln('OK') else writeln('Failed')
end.
