program Carel2i;

type
   pword = ^cardinal;
   cardinal = boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end.
