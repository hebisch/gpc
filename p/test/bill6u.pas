unit bill6ubar;
interface
Var Lst:Text;
implementation
Procedure Assign ( Var T : Text; Const Name : String );
Var
  B : BindingType;
Begin {* Assign *}
  unbind ( T );
  B := binding ( T );
  B.Name := Name;
  bind ( T, B );
  B := binding ( T );
End {* Assign *};
Begin
Assign(Lst,'bill6.dat');
rewrite(Lst);
End.
