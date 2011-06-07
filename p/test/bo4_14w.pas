Unit BO4_14w;

Interface

uses
  BO4_14u, BO4_14v;  { superfluous, but correlated with the error }

Var
  O: record
    K: pString;
  end { OK };

Procedure Print ( S: String );

Implementation

Procedure Print ( S: String );

begin { Print }
  writeln ( S );
end { Print };

end.
