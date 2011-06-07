Program fjf57;

{$X+}

function StrLen (Src : CString) : SizeType;
var Temp : CString;
begin
  Temp := Src;
  while Temp^ <> #0 do Inc (Temp);
  StrLen := Temp - Src
end;

var
  O : array [3 .. 5] of Char = 'OK'#0;
  K : CString;

begin
  K := O;
  if StrLen (K) = 2 then WriteLn (K) else WriteLn (StrLen (K), ' `', K, '''')
end.
