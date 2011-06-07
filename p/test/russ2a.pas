Unit russ2a;

INTERFACE

TYPE
  RRType = (rr_zero,rr_one,rr_two,rr_three,rr_four);
  OneObj = OBJECT
    a  : Integer;
    procedure aaa(r : RRType);
  end;

procedure aaa;

IMPLEMENTATION

procedure OneObj.aaa(r : RRType);
begin
  if r = rr_one then writeln ('OK') else writeln ('failed')
end;

procedure aaa;
begin
end;

end.
