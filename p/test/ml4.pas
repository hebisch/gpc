Program ml4;
Var Magic:Integer;

begin
  Magic:=Ord('A')-Ord('a');
  if Succ ('a', Magic) = 'A' then WriteLn ('OK') else WriteLn ('failed')
end.
