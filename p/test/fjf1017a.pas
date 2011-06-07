{$nested-comments}

program fjf1017a;

{ This is *no* nested comment because `(*)' is interpreted as
  standard-conformant `( *)' rather than `(* )'. }

(* (*)

begin
  WriteLn ('OK')
end.
