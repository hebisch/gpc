program az42(output);
const s=1;
type t=^s; (* WRONG *)
begin
  writeln('failed')
end.
