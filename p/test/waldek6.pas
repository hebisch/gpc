PROGRAM FOO;
CONST
    IDLNGTH     = 12;
TYPE
    ALPHA        = ARRAY [1..IDLNGTH] OF CHAR;
    IDENTIFIER   = PACKED RECORD
                    NAME: ALPHA;
                   END;
VAR
    FILID : IDENTIFIER ;
    I, J : INTEGER;

BEGIN
    J := 0 ;
    FOR I := 1 TO IDLNGTH DO J := J + ORD(FILID.NAME[I]) ;
    WRITELN('OK')
END
.
