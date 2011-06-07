{$R+}

program rangecheck3;

var i: 1..5;

begin
         i:= 5;
{$local R-}
         i:= i+1;
{$endlocal}
         if i = 6 then WriteLn ('OK') else WriteLn ('failed ', i)
end.
