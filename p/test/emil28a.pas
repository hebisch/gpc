program Test (output);

type
        colour = (red, yellow, green, blue);
        { from ISO 10206, 6.4.10 }
        colour_map (formal_discriminant: colour) =
                record
                case formal_discriminant of
                  red:    (red_field:    integer value ord (red));
                  yellow: (yellow_field: integer value ord (yellow));
                  green:  (green_field:  integer value ord (green));
                  blue:   (blue_field:   integer value ord (blue));
                end;
        cmap_blue = colour_map (blue);

const
        cb = cmap_blue [case blue of [blue_field: 42]];

var
        cg: colour_map (green);

begin
  if (cb.blue_field = 42) and (cg.green_field = 2) then writeln ('OK')
  else writeln ('failed ', cb.blue_field, ' ', cg.green_field)
end.
