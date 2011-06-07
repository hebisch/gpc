program mir034a;
{Val with source out of bounds}
type range = 10..13;
var k : range;
    ec : Integer;

begin
   Val ('14', k, ec); { over ubound }
   if ec = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
