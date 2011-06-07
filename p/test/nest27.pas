{$nested-comments,W nested-comments}

Program Nest27;

{$W-} { This is a { nested } comment. } {$W+}
begin
{$W-} (* So is (* this *) one. *) {$W+}
  writeln ( 'OK' );
end.
