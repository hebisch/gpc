MODULE David1m interface;
   export David1m=(Test_proc);

   PROCEDURE Test_proc(List : ARRAY[a..b :INTEGER] OF DOUBLE);
END.

MODULE David1m implementation;

PROCEDURE Test_proc;

   BEGIN
      List[a]:= 2.3;
      List[2]:= 2.3;
   END; { Test_proc }

END.
