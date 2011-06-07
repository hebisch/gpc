program drf8;

Type
  Days    = (Mo,Tu,We,Th,Fr,Sa,Su);  { This is an enumerated type }
  Working = Mo..Fr;                  { This is a subrange of Days }

begin
  if (Low (Working) = Low (Days)) and (High (Working) = Pred (High (Days), 2))
    then WriteLn ('OK')
    else WriteLn ('failed')
end.
