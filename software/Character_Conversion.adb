with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Interfaces; use Interfaces;

function Character_Conversion (my_char : Character) return Unsigned_8 is
   the_char : Character := my_char;
   the_byte : Unsigned_8 := Unsigned_8 (Character'Pos (the_char));

begin
   return the_byte;

end Character_Conversion;
