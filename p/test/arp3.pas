program verRELset ( output ) ;
{gpc -fextended-pascal verRELset.pas}
type
  tMin  = 'a'..'z';
  tCMin = set of tMin;

const
  vowels = tCMin['a', 'e', 'i', 'o', 'u'];

var
  CM1, CM2 : tCMin;
  m        : tMin;
begin
   CM1 := ['a'..'r'] ;
   CM2 := ['j'..'l'] ;
   if CM1 < CM2 then writeln('CM1 < CM2'); {not standard}
   if CM1 > CM2 then writeln('CM1 > CM2'); {not standard}
   for m := 'a' to 'z' do
      if m in vowels then write ( m ); {right!}
{  for m in vowels do write ( m ); constant out of range }
end.
