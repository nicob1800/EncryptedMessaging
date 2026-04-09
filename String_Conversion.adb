with Character_Conversion;
with Interfaces; use Interfaces;

package body String_Conversion is

   function String_To_Bytes (my_string : String) return byte_array is
      string_length : constant Integer := my_string'Length;
      string_array  : byte_array (1 .. string_length);
   begin
      for i in 1 .. string_length loop
         string_array (i) := Character_Conversion (my_string (i));
      end loop;

      return string_array;
   end String_To_Bytes;

end String_Conversion;
