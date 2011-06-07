program StringU2tilsTest;

uses GPC, StringUtils;

procedure Test (const s: String; c: CharSet);
var
  i: Integer;
  p: PPStrings;
begin
  WriteLn ('>', s);
  p := TokenizeString (s, c);
  WriteLn (p^.Count);
  for i := 1 to p^.Count do WriteLn (p^[i]^);
  DisposePPStrings (p)
end;

begin
  Test ('', ['x']);
  Test ('x', ['x']);
  Test ('xx', ['x']);
  Test ('y', ['x']);
  Test ('|Frank|Peter|Chief|||Maurice||', ['|']);
  Test ('|Frank|Peter|Chief|||Maurice|', ['|']);
  Test ('Frank|Peter|Chief|||Maurice|', ['|']);
  Test ('|Frank|Peter|Chief|||Maurice', ['|']);
  Test ('Frank|Peter|Chief|||Maurice', ['|']);
end.
