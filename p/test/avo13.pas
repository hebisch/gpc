program testsubrange;

type
   int16 = integer attribute( size = 16);
   int32 = integer attribute( size = 32);
   point = record x,y: array [1 .. 8] of Byte end; {takes 16 bytes}

var
    i: int16;

procedure P( size: int32);
begin
  if size = 58528 then WriteLn ('OK') else WriteLn ('failed: ', 'size = ', size)
end;

begin
    i:= 3658;
    P( i * SizeOf( point));
end.
