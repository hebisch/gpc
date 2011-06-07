program ice4;

type
   Str9   = record sLength: Byte; sChars: packed array[ 1..  9] of char
end;
   Str255 = record sLength: Byte; sChars: packed array[ 1..255] of char
end;

operator + ( const s1: Str9; const s2: Str255 ) = theResult : Str255;
operator + ( const s1: Str9; const s2: Str255 ) = theResult : Str9;

procedure P;
var
   s1: Str9;
   s2: Str255;
begin
   s1:= s1 + s2
end;

begin
end.
{ WRONG }
