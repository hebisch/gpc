{ Problem: Global file variables (in the program or in units) must
  *not* be cleaned up (DoneFDR) in the program's/unit's destructor
  because they might still be needed. (They will be cleaned up by
  the RTS' finalize mechanism later.) }

program fjf464a;

uses fjf464u;

var
  t : Text;

begin
  Rewrite (t, '-');
  p := @t
end.
