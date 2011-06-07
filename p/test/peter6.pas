program test (output);

type t = record
     f1 : integer;
     case tag : integer of
     0: (i : integer);
     1: (r : real);
     end;

{ The original report omitted the `r:', but both EP and BP demand
  the field name, so I'm not sure if we should support it without it
  ... -- Frank }

var  r : t value (1, 1, r: 3.14);
begin
  if (r.f1 = 1) and (r.tag = 1) and (Abs (r.r - 3.14) < 0.000001) then WriteLn ('OK') else WriteLn ('failed ', r.f1, ' ', r.tag, ' ', r.r)
end.
