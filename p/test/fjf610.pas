{
  GPC crashed with `-g' in a complex program with many units.

  The present test didn't reproduce the crash per se, but (before the fix)
  it could be used to show some obstack problems by inserting in
  parse.y: assignment_or_call_statement, before the latter expand_expr_stmt() call
  the following code:

  print_obstack_name (source, stderr, ""); debug_tree (source);
  print_obstack_name (TREE_TYPE (source), stderr, ""); debug_tree (TREE_TYPE (source));
  print_obstack_name (TYPE_DOMAIN (TREE_TYPE (source)), stderr, ""); debug_tree (TYPE_DOMAIN (TREE_TYPE (source)));
  print_obstack_name (TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (source))), stderr, ""); debug_tree (TYPE_MIN_VALUE (TYPE_DOMAIN (TREE_TYPE (source))));
}

{ FLAG -Wno-unused }

program fjf610;

procedure P;
var
  xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  edcaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  cddaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  caedaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  caaaeadaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  dcaaaeaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  cdaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
  cadaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: Integer;
  a: array [1 .. 2] of Integer;
begin
end;

var
  b: array [1 .. 2] of Integer;

begin
  b := b;
  WriteLn ('OK')
end.
