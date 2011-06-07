{ Note: It is questionable whether this program is valid at all
  (because of the two meanings of `a'). There might even be an
  inconsistency in the standard. See the (long!) thread of
  <news:c9660953.0212021430.56bc7065@posting.google.com> for the
  full discussion.

  The program is non-standard: EP 6.2.2.11 requires that identifiers
  have single meaning (other programs are invalid). Since many
  other compilers accept program below we may also accept it
  in defalut mode. (Waldek Hebisch)

  However, *if* the program is valid, it must behave as tested
  here, with the different meanings of `x.a := a' inside and
  outside of the `with' statement. }

program fjf728a (Output);

var
  x: record
       a: (a, b)
     end;

begin
  x.a := b;
  with x do
    x.a := a;  { assign x.a to itself, i.e. do nothing }
  if Ord (x.a) <> 1 then
    WriteLn ('failed 1')
  else
    begin
      x.a := a;  { assign the enum value a to x.a }
      if Ord (x.a) <> 0 then
        WriteLn ('failed 2')
      else
        WriteLn ('OK')
    end
end.
