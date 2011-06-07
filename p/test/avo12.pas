program avo12;

type
         Str255 = record sLength: Byte; sChars: packed array[1..255] of
char; end;

  function StringToStr255 ( const s: String ) = Result : Str255;
   begin
     Result.sLength := Min( Length( s ), 255 );
     if Result.sLength > 0 then begin
       Result.sChars[1..Result.sLength] := s[1..Result.sLength];
     end;
   end;

procedure DrawString1( const s: Str255); external name 'DrawString';
procedure DrawString2( protected var s: Str255); external name
'DrawString';

begin
         DrawString1( StringToStr255( 'Hello')); {OK}
         DrawString2( StringToStr255( 'Hello'))  {Error: reference
expected, value given}  { WRONG }
end.
