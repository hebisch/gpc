program Bug1(Input,Output);

type
 Str255=String(255);

procedure Gogo(S:String; var SOut:Str255);
 begin
{
  WriteLn(' Before Error ');
  writeln ( 'S = ', S );
  writeln ( 'SOut = ', S );
}
  S:= 'xy';
{
  writeln ( 'S = ', S );
  writeln ( 'SOut = ', S );
}
  SOut:='OK';      { ! ?GPC runtime error: runtime error (#-1) ! }
{
  WriteLn(' After Error ');
}
 end;

var
 S:Str255;
begin
 S:='1234';
 Gogo(S,S);
 writeln ( S );
end.
