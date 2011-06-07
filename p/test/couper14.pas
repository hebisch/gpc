Unit couper14;

Interface

Type
  P_Vecteur = ^T_Vecteur = Nil;
  T_Vecteur(N:Cardinal) = Array [1..N] Of LongReal;

Implementation

Procedure AddVecteurs(Resultat,A,B:P_Vecteur);
  Var
    Taille : Integer;
    Tampon : P_Vecteur;
  Procedure Addition(Resultat,AA,BB:P_Vecteur);
    Var
      I : Integer;
    Begin
      For I := 1 To Taille
        Do Resultat^[I] := AA^[I] + BB^[I]
    End;
  Begin
  End;

Procedure DiffVecteurs(Resultat,A,B:P_Vecteur);
  Var
    Taille : Integer;
    Tampon : P_Vecteur;
  Procedure Soustraction(Resultat,AA,BB:P_Vecteur);
    Var
      K : Integer;
    Begin
      For K := 1 To Taille Do Resultat^[K] := AA^[K] - BB^[K]
    End;
  Begin
  End;

Begin
End.
