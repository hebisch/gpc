program Adriaan1;
type int64 = integer attribute (Size = BitSizeOf (double));
var r: double; l: int64;
begin
   l:= 0;
   int64( r):=l;
{   writeln( 'r = ', r); }
   r:= -1;
   double( l):= r;
{   writeln( 'l = ', l) }

   { The actual values depend on the floating point format. However, it
     should be rather safe to assume that -1 in floating point does not
     have the same representation as an Integer -1. So l = -1 indicates
     a wrong cast done by the compiler. }
   if l <> -1 then WriteLn ('OK') else WriteLn ('failed')
end.
