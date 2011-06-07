{OK}

Program SBerend;

Type
  ByteFile = file of Byte;

Var
  F: ByteFile;
  C: Byte;

begin
  Assign ( F, ParamStr (1) );
  reset ( F );
  read ( F, C );
  read ( F, C );
  write ( chr ( C ) );
  read ( F, C );
  writeln ( chr ( C ) );
  close ( F );
end.
