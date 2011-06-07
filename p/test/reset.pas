program test(input, output);
var f:  text;
begin
   {$I-}
   reset(f, '...  ');
   {$I+}
   if IOResult <> 0 then WriteLn ('OK') else WriteLn ('failed')
end.
