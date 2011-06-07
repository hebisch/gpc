program setbug(input,output);

CONST
        FirstChar = ['+','-','0'..'9'];
#ifdef FIX
        GoodChar  = ['+','-','0'..'9','.','e','E'];
#else
        GoodChar  = FirstChar+['.','e','E'];
#endif

VAR
        ch:CHAR;
        in_set:BOOLEAN;

BEGIN
        ch:='0';
        in_set:= ch IN GoodChar;
        if in_set then
          writeln ( 'OK' )
        else
          writeln ( 'failed' );
END.
