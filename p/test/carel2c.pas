program Carel2c;

type
   pword   = ^Integer;
   Integer = boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end.
