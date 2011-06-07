program Carel2h;

type
   pword = ^cardinal;
   word = boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := 42;
   if pw^ = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
