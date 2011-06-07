{ FLAG --classic-pascal }

program fjf691 (Output);

   CONST
      maxstring = 20;
      maxtable  = 5;

   TYPE
      tblindex = 1..maxtable;
      strindex = 1..maxstring;
      astring  = ARRAY[strindex] OF char;


   VAR
      idtable: ARRAY[tblindex] OF astring;
      BEGIN
                  { 12345678901234567890 }
      idtable[1] := 'stuff               ';  { WRONG }

  WriteLn ('failed')
end.
