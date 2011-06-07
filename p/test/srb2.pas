program Bug2(Input,Output);

type
 Str255=String(255);
var
 I:Integer;

function Gogo(S:String):Str255;
 begin
  WriteLn('OK');
  Inc(I);
  Gogo:=S;
 end;

var
 S:Str255;
begin
 I:=0;
 S:='1234';
 S:=Gogo(S); { ! No one call Gogo bat three calls ! }
 if I <> 1 then
   WriteLn(I); { ! I=3   I!=0 }
end.
