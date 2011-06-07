unit sam12_u;
interface
uses sam12_e;
procedure u_proc(e: t_e);
implementation
procedure u_proc;
  begin
    if e = e_a then writeln ('OK') else writeln ('failed')
  end;
begin
end.
