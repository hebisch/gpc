program daj14a(input,output);
const maxnum=4;
TYPE
     T1=RECORD
         a1:array[1..maxnum] of byte;
        END;
     T2=RECORD
         a2:packed array[1..maxnum] of byte;
        END;
     T3=RECORD
         a3:packed array[1..maxnum] of 0..255;  { works with `packed 0..255' -- GPC should do this implicitly }
        END;
     T4=RECORD
         a4:array[1..maxnum] of 0..255;
        END;

BEGIN
  if sizeof(T1) <> maxnum * sizeof (byte) then BEGIN writeln ('failed 1'); halt END;
  if sizeof(T2) <> maxnum * sizeof (byte) then BEGIN writeln ('failed 2'); halt END;
  if sizeof(T3) <> maxnum * sizeof (byte) then BEGIN writeln ('failed 3 ', sizeof(T3), ' ', maxnum * sizeof (byte)); halt END;
  if sizeof(T4) <> maxnum * sizeof (Integer) then BEGIN writeln ('failed 4'); halt END;
  writeln ('OK')
END.
