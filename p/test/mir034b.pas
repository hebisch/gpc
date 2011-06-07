program mir034b;
{Val with source out of bounds}
type range = 10..13;
var k : range;
    ec : Integer;

begin
   Val ('7', k, ec); { bellow lbound }
   if ec = 1 then WriteLn ('OK') else WriteLn ('failed')
end.
