Unit Jesper1v;

Interface

uses
  Jesper1u;

Procedure Bar ( R: FooRec );

Implementation

Procedure Bar ( R: FooRec );

begin { Bar }
  writeln ( R.OK );
end { Bar };

end.
