program Carel2d;

type
   pword = ^Byte;
   Byte  =  boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end.
