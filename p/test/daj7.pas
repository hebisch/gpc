program daj7(input,output);

const MAXCONTROL = 170;
      maxcomp = 200;
type
     TCHECK1=PACKED RECORD
            CHECH:0..47;        {6 bits}
            CHECM:0..60;        {6 bits}
            CHECS:0..60;        {6 bits}
            CHECT:0..999;       {10 bits}
            GENERATED:BOOLEAN;
            QUERY:BOOLEAN;
            from_audit:BOOLEAN;
      END;
     TCHECK= PACKED ARRAY [0..MAXCONTROL] OF TCHECK1;
                 { if declared as PACKED, get error 405 on the rewrite
                                  if not declared PACKED, runs OK }

var count:integer;
    f:FILE [0..maxcomp] OF TCHECK;

BEGIN
 rewrite(f,'daj7.dat');
   {./daj7: could not open `daj7.dat' (error #405) here }

 for count:=0 to maxcomp do
  BEGIN
   seekwrite(f,count);
   f^[0].CHECT:=count;
   put(f);
  END;
 close(f);

 reset(f,'daj7.dat');
 for count:=1 to maxcomp do
  BEGIN
   seekread(f,count);
   if f^[0].CHECT <> count then
     BEGIN
       writeln ('failed ', count);
       halt
     END
  END;
 close(f);
 writeln ('OK')
END.
