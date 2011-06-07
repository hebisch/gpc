program Carel2e;

type
   pword = ^Min;
   Min   =  boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end.
