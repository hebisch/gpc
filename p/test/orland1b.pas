UNIT orland1b;
INTERFACE

USES
  Orland1a;

PROCEDURE PutImg( zClipRect : TClipRect );

IMPLEMENTATION
PROCEDURE PutImg( zClipRect : TClipRect );
BEGIN
  WriteLn (zClipRect.MinX)
END;
END.
