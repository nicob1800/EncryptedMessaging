with Interfaces;
with String_Conversion; use String_Conversion;

package Bridge is
   type Bridge_Status is
     (Ok, Output_Missing, Timeout, Length_Mismatch, Io_Error);

   procedure Transfer_Payload
     (In_Payload       : in byte_array;
      Out_Payload      : out byte_array;
      Status           : out Bridge_Status;
      Counter          : in Interfaces.Unsigned_16 := 0;
      Timeout_Seconds  : in Duration := 2.0;
      Input_File_Name  : in String := "payload_to_enc.bin";
      Output_File_Name : in String := "enc_to_payload.bin");
end Bridge;
