Program TestCopy;

Var
  Chaine         : String(1296); {That's the value I need in my real program}
  SousChaine     : String(9);
  LongueurChaine : MedWord;
  IndexPosition  : MedWord;

Begin
  Chaine := '1000000000';
  LongueurChaine := Length(Chaine);

  SousChaine := Copy(Chaine,LongueurChaine - 8,9); {Here is the problem}
  Writeln('SousChaine : ',SousChaine); {Writes nothing !}
  Writeln('Length(SousChaine) : ',Length(SousChaine)); {Writes 0}

  IndexPosition := LongueurChaine - 8;
  SousChaine := Copy(Chaine,IndexPosition,9); {Now it works}
  Writeln('SousChaine : ',SousChaine); {Writes 000000000}
  Writeln('Length(SousChaine) : ',Length(SousChaine)); {Writes 9}

  {There is no problem with the "Delete" procedure :}
  Delete(Chaine,LongueurChaine - 8,9);
  Writeln('Chaine : ',Chaine) {Writes 1}
End.
