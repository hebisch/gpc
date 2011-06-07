MODULE mSietse2m;

EXPORT
   Sietse2m = ( B );

{ removing the next 2 lines resolves the issue. }
IMPORT
   StandardOutput;

PROCEDURE B;
END;

PROCEDURE B;
   BEGIN
     WriteLn ('OK')
   END;

END.
