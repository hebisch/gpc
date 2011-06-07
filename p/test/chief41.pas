Program chief41;

Type
Charset = Set of Char;

function Str2Charset (S: string) = Res : Charset;
var i : Integer;
begin
  Res := [];
  for i := 1 to Length (S) do
    Include (Res, S [i])
end;

var
c : Charset;
begin
   c := Str2Charset ('\/:');
   if c = ['\', '/', ':'] then WriteLn ('OK') else WriteLn ('failed')
end.
