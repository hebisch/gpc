{$gnu-pascal}

unit Dialec5u;

interface

procedure UnredirectOutput;

implementation

procedure UnredirectOutput;
begin
  Assign (Output, '');
  Rewrite (Output)
end;

end.
