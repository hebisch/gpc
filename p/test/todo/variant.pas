program var1;
{$extended-pascal}
type  RS = RECORD
    CASE INTEGER OF
      0: (RSSS: INTEGER);
      1: (RSTI: INTEGER);
      (* WRONG  -- variants do not exhaust integer values *)
    END;
begin
end
.

