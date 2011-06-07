program Eike3a;

var
  MySet: Set of Char = ['b', 'a', 'r'];

begin
  if (Card (MySet) = 3)                { works }
     and (Card (['f', 'a', 'i', 'l']) = 4)  { fails }
    then WriteLn ('OK') else WriteLn ('failed')
end.
