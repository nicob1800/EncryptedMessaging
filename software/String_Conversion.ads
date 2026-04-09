with Character_Conversion;
with Interfaces; use Interfaces;

package String_Conversion is
   type byte_array is array (Positive range <>) of Unsigned_8;

   function String_To_Bytes (my_string : String) return byte_array;
end String_Conversion;
