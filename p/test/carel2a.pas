program Carel2a;

type
   pword = ^word;
   word  =  boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end.
