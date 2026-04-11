with Ada.Text_IO;       use Ada.Text_IO;
with GNAT.Sockets;      use GNAT.Sockets;
with String_Conversion; use String_Conversion;
with Interfaces;        use Interfaces;
with Message_Protocol;  use Message_Protocol;

procedure client is
   Server_IP     : constant String := "127.0.0.1";
   Client_Socket : Socket_Type;
   Address       : Sock_Addr_Type;
   Channel       : Stream_Access;
   Input_Buffer  : String (1 .. 200);
   Last          : Natural;
   Sender_ID     : Unsigned_16 := 0;
   Counter       : Unsigned_16 := 0;

   task Receiver is
      entry Start (Incoming_Channel : Stream_Access);
   end Receiver;

   task body Receiver is
      Local_Channel   : Stream_Access := null;
      Incoming_Message : Full_Message;
   begin
      accept Start (Incoming_Channel : Stream_Access) do
         Local_Channel := Incoming_Channel;
      end Start;

      loop
         Read_Header
           (Incoming_Message.Message_Header,
            Local_Channel,
            Incoming_Message.Status);
         exit when Incoming_Message.Status /= Ok;

         declare
            Payload_Length : constant Unsigned_16 :=
              Incoming_Message.Message_Header.Message_Length;
            Payload_Buffer : byte_array (1 .. Positive (Payload_Length));
            Text           : String (1 .. Positive (Payload_Length));
         begin
            Read_Payload
              (Payload_Buffer,
               Payload_Length,
                      Local_Channel,
               Incoming_Message.Status);

            exit when Incoming_Message.Status /= Ok;

            for Index in Payload_Buffer'Range loop
               Text (Index) :=
                 Character'Val (Integer (Payload_Buffer (Index)));
            end loop;

            Put_Line
              ("[incoming] from"
               & Unsigned_16'Image (Incoming_Message.Message_Header.Sender_ID)
               & " ->"
               & Unsigned_16'Image
                   (Incoming_Message.Message_Header.Receiver_ID)
               & ": "
               & Text);
         end;
      end loop;
   exception
      when others =>
         Put_Line ("Receiver closed.");
   end Receiver;

   function Read_ID (Prompt : String) return Unsigned_16 is
      Buffer : String (1 .. 20);
      Final  : Natural;
   begin
      Put (Prompt);
      Get_Line (Buffer, Final);
      return Unsigned_16'Value (Buffer (1 .. Final));
   end Read_ID;

   procedure Print_Message (Message_Header : Header; Payload : byte_array) is
      Text : String (1 .. Payload'Length);
   begin
      for Index in Payload'Range loop
         Text (Index) := Character'Val (Integer (Payload (Index)));
      end loop;

      Put_Line
        ("Received from"
         & Unsigned_16'Image (Message_Header.Sender_ID)
         & " ->"
         & Unsigned_16'Image (Message_Header.Receiver_ID)
         & ": "
         & Text);
   end Print_Message;
begin
   Put ("Connecting to " & Server_IP & "...");
   Create_Socket (Client_Socket);
   Address.Addr := Inet_Addr (Server_IP);
   Address.Port := 12345;
   Connect_Socket (Client_Socket, Address);
   Put_Line ("Connected.");

   Sender_ID := Read_ID ("Enter your client ID: ");

   Channel := Stream (Client_Socket);
   Receiver.Start (Channel);

   declare
      Register_Header  : Header;
      Register_Message : byte_array (1 .. 1) := (others => 0);
      Register_Status  : Protocol_Status;
   begin
      Register_Header.Sender_ID := Sender_ID;
      Register_Header.Receiver_ID := 0;
      Register_Header.Message_Length := 0;
      Register_Header.Counter := 0;
      Write_Message
        (Register_Header,
         Register_Message,
         Channel,
         Register_Status);
   end;

   loop
      Put ("Enter message (quit to stop): ");
      Get_Line (Input_Buffer, Last);

      if Last = 0 or else Input_Buffer (1 .. Last) = "quit" then
         exit;
      end if;

      declare
         Message_To_Send : constant String := Input_Buffer (1 .. Last);
         Bitwise_Message : byte_array := String_To_Bytes (Message_To_Send);
         Receiver_ID     : Unsigned_16;
         Message_Header  : Header;
         Send_Status     : Protocol_Status;
      begin
         Receiver_ID := Read_ID ("Send to client ID: ");

         Counter := Counter + 1;
         Message_Header.Sender_ID := Sender_ID;
         Message_Header.Receiver_ID := Receiver_ID;
         Message_Header.Message_Length := Unsigned_16 (Bitwise_Message'Length);
         Message_Header.Counter := Counter;

         Put_Line ("Sending message...");
         Write_Message (Message_Header, Bitwise_Message, Channel, Send_Status);
         if Send_Status /= Ok then
            Put_Line ("Send failed.");
            exit;
         end if;
      end;
   end loop;

   Close_Socket (Client_Socket);
end client;
