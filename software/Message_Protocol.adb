with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

package body Message_Protocol is

    procedure Write_Message
       (Message_Header  : Header;
        Message_Payload : byte_array;
        Channel         : Stream_Access) is
    begin
        Unsigned_16'Write (Channel, Message_Header.Sender_ID);
        Unsigned_16'Write (Channel, Message_Header.Receiver_ID);
        Unsigned_16'Write (Channel, Message_Header.Message_Length);
        Unsigned_16'Write (Channel, Message_Header.Seed);
        Unsigned_16'Write (Channel, Message_Header.Counter);
        for char of Message_Payload loop
            Unsigned_8'Write (Channel, char);
        end loop;

    end Write_Message;

    procedure Read_Header
       (Message_Header : out Header; Channel : Stream_Access) is
    begin
        Message_Header.Sender_ID := Unsigned_16'Input (Channel);
        Message_Header.Receiver_ID := Unsigned_16'Input (Channel);
        Message_Header.Message_Length := Unsigned_16'Input (Channel);
        Message_Header.Seed := Unsigned_16'Input (Channel);
        Message_Header.Counter := Unsigned_16'Input (Channel);

    end Read_Header;

    procedure Read_Payload
       (Message_Payload : out byte_array;
        Payload_Length  : Unsigned_16;
        Channel         : Stream_Access)
    is
        Length_Integer : Integer := Integer (Payload_Length);
    begin
        if (Message_Payload'Length = Length_Integer) and Length_Integer /= 0
        then
            for I in 1 .. Length_Integer loop
                Message_Payload (I) := Unsigned_8'Input (Channel);

            end loop;
        else
            Put ("***ERROR: Payload length value does not match!***");
        end if;

    end Read_Payload;

end Message_Protocol;
