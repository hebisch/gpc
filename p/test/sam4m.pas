Module Sam4m;

Procedure OK; { was `external;', but that's not true. -- Frank, 20030303 } attribute (name = 'OK');
begin { OK }
  writeln ( 'OK' );
end { OK };

end.
