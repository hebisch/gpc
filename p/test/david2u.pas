UNIT David2u;

Interface
   PROCEDURE Test_proc(List : ARRAY[a..b :INTEGER] OF DOUBLE);

Implementation

PROCEDURE Test_proc;

   BEGIN
      List[a]:= 2.3;
      List[2]:= 2.3;
   END; { Test_proc }

END.
