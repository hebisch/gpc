program fjf824d;

type
  TString = String (2048);

var
  s: TString;

{$I-}
function f: TString;
var t: Text;
begin
  Reset (t);
  f := 'OK'
end;
{$I+}

begin
  s := f;
  InOutRes := 0;
  WriteLn (s)
end.
