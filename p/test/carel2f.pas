program Carel2f;

type
  word = char;

procedure foo;
type
   pword = ^word;
   word  =  boolean;

var
   pw    : pword;

begin
   new(pw);
   pw^ := true;
   if pw^ then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  foo
end.
