MODULE msge INTERFACE;
EXPORT msge = ( IsoString, getfilename);
TYPE   IsoString (Capacity : Integer) =   array [1 .. Capacity + 1] of Integer;
PROCEDURE getfilename (VAR fnm: IsoString; fext: IsoString);
END.

MODULE msge IMPLEMENTATION;

VAR fextt : IsoString(30);

PROCEDURE set_suffix (VAR fnm: IsoString;   fext: IsoString);
   BEGIN
   END;

PROCEDURE getfilename;
   BEGIN
      set_suffix (fnm, fext);
   END;

END.
