with String_Conversion; use String_Conversion;
with Ada.Text_IO;       use Ada.Text_IO;
with Interfaces;        use Interfaces;

procedure test is
   output : byte_array :=
     String_To_Bytes ("!@#$%^&*()_-+=''""\|]}[{}];:/?.>,<`~");
   size   : Integer := output'Length;
begin
   for I in 1 .. size loop
      Put_Line (Unsigned_8'Image (output (I)));
   end loop;
end;
