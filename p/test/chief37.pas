program chief37;
var
i, code : longint;
begin
   Val ('$FFFF', i, code);
   If (i = $FFFF) and (code = 0) then WriteLn ('OK') else WriteLn ('Bug: ', i, ' ', code);
end.
