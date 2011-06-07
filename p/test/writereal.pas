{ Contributed by acahalan@cs.uml.edu under the 2-clause BSD license.

  Slightly modified by Frank Heckenbach: inserted `+1e-24' etc. in
  various places because of rounding inaccuraccies.

  These tests are rather fragile due to the text comparison with
  writereal.out. If this turns out to become a bigger problem, we
  might have to read the values back in Pascal code and compare them
  with some tolerance, see read*.pas. }

PROGRAM giga ( input,output ) ;

var w:Integer;
    p:Integer;
    t:Text;
    s:String (200);
    i:Integer;

begin
   Rewrite (t);

   w := 44;
   p := 0;

   writeln(t, '''', 9.999e9, '''');
   writeln(t, '''', 9.999e9:w, '''');
   writeln(t, '''', 9.999e9:w:p, '''');
   writeln(t, '''', 7.777e9:w:p, '''');
   writeln(t, '''', 9.999e-10, '''');
   writeln(t, '''', 9.999e-10+1e-24:w, '''');
   writeln(t, '''', 9.999e-10:w:p, '''');
   writeln(t, '''', 7.777e-10:w:p, '''');
   writeln(t, '''', 123.456, '''');
   writeln(t, '''', 123.456+1e-12:w, '''');
   writeln(t, '''', 123.456:w:p, '''');
   writeln(t, '''', 0.0001e-9+1e-27, '''');
   writeln(t, '''', 0.0001e-9+1e-27:w, '''');
   writeln(t, '''', 0.0001e-9:w:p, '''');
   writeln(t, '''', 0.0001e-10+1e-28, '''');
   writeln(t, '''', 0.0001e-10+1e-28:w, '''');
   writeln(t, '''', 0.0001e-10:w:p, '''');
   writeln(t, '''', -9.999e9, '''');
   writeln(t, '''', -9.999e9:w, '''');
   writeln(t, '''', -9.999e9:w:p, '''');
   writeln(t, '''', -7.777e9:w:p, '''');
   writeln(t, '''', -9.999e-10, '''');
   writeln(t, '''', -9.999e-10-1e-24:w, '''');
   writeln(t, '''', -9.999e-10:w:p, '''');
   writeln(t, '''', -7.777e-10:w:p, '''');
   writeln(t, '''', -123.456, '''');
   writeln(t, '''', -123.456-1e-12:w, '''');
   writeln(t, '''', -123.456:w:p, '''');
   writeln(t, '''', -0.0001e-9-1e-27, '''');
   writeln(t, '''', -0.0001e-9-1e-27:w, '''');
   writeln(t, '''', -0.0001e-9:w:p, '''');
   writeln(t, '''', -0.0001e-10-1e-28, '''');
   writeln(t, '''', -0.0001e-10-1e-28:w, '''');
   writeln(t, '''', -0.0001e-10:w:p, '''');

{$if False}  { Can crash on non-IEEE FP implementations }
   writeln(t, '''', (-0.0)/0.0:w:p, '''');
   writeln(t, '''',   0.0 /0.0:w:p, '''');
   writeln(t, '''', (-1.0)/0.0:w:p, '''');
   writeln(t, '''',   1.0 /0.0:w:p, '''');
{$endif}
   writeln(t, '''', (-0.0)/1.0:w:p, '''');
   writeln(t, '''',   0.0 /1.0:w:p, '''');
   writeln(t, '''', (-1.0)/1.0:w:p, '''');
   writeln(t, '''',   1.0 /1.0:w:p, '''');
{$if False}  { Can crash on non-IEEE FP implementations }
   writeln(t, '''', (-0.0)/(-0.0):w:p, '''');
   writeln(t, '''',   0.0 /(-0.0):w:p, '''');
   writeln(t, '''', (-1.0)/(-0.0):w:p, '''');
   writeln(t, '''',   1.0 /(-0.0):w:p, '''');
{$endif}
   writeln(t, '''', (-0.0)/(-1.0):w:p, '''');
   writeln(t, '''',   0.0 /(-1.0):w:p, '''');
   writeln(t, '''', (-1.0)/(-1.0):w:p, '''');
   writeln(t, '''',   1.0 /(-1.0):w:p, '''');

   writeln(t);

   { Compensate for differences in accurary and rounding between systems. }
   Reset (t);
   while not EOF (t) do
     begin
       ReadLn (t, s);
       i := 18;
       while (i <= Length (s)) and (s[i] in ['0' .. '9']) do
         begin
           s[i] := '0';
           Inc (i)
         end;
       writeln (s)
     end

end.
