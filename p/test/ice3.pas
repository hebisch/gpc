program ice3;

type
   Str44 = record sLength: Byte; sChars: packed array[ 1..44] of char
end;

procedure P (s: str44); forward;

procedure P (const s: str44); { WRONG }
begin
end;

begin
end.
