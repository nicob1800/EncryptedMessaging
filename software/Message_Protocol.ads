with Interfaces;        use Interfaces;
with GNAT.Sockets;      use GNAT.Sockets;
with String_Conversion; use String_Conversion;

package Message_Protocol is
   type Protocol_Status is (Ok, Bad_Length, Stream_Error);

   type Header is record
      Sender_ID      : Unsigned_16;
      Receiver_ID    : Unsigned_16;
      Message_Length : Unsigned_16;
      Counter        : Unsigned_16;
   end record;

   procedure Write_Message
     (Message_Header  : Header;
      Message_Payload : byte_array;
      Channel         : Stream_Access;
      Status          : out Protocol_Status);

   procedure Read_Header
     (Message_Header : out Header;
      Channel        : Stream_Access;
      Status         : out Protocol_Status);

   procedure Read_Payload
     (Message_Payload : out byte_array;
      Payload_Length  : Unsigned_16;
      Channel         : Stream_Access;
      Status          : out Protocol_Status);

end Message_Protocol;
