with Ada.Text_IO;       use Ada.Text_IO;
with GNAT.Sockets;      use GNAT.Sockets;
with Interfaces;        use Interfaces;
with Message_Protocol;  use Message_Protocol;
with String_Conversion; use String_Conversion;

procedure server is
   Max_Clients : constant Positive := 32;

   type Socket_Access is access all Socket_Type;

   type Registry_Entry is record
      In_Use            : Boolean := False;
      Registered_ID     : Unsigned_16 := 0;
      Registered_Socket : Socket_Access := null;
   end record;

   type Registry_Array is
       array (Positive range 1 .. Max_Clients) of Registry_Entry;

   protected type Client_Registry is
      procedure Register
        (Client_ID : Unsigned_16; Client_Socket : Socket_Access);
      procedure Unregister (Client_ID : Unsigned_16);
      function Find (Client_ID : Unsigned_16) return Socket_Access;
   private
      Entries : Registry_Array;
   end Client_Registry;

   protected body Client_Registry is
      procedure Register
        (Client_ID : Unsigned_16; Client_Socket : Socket_Access) is
      begin
         for Index in Entries'Range loop
            if not Entries (Index).In_Use
              or else Entries (Index).Registered_ID = Client_ID
            then
               Entries (Index).In_Use := True;
               Entries (Index).Registered_ID := Client_ID;
               Entries (Index).Registered_Socket := Client_Socket;
               exit;
            end if;
         end loop;
      end Register;

      procedure Unregister (Client_ID : Unsigned_16) is
      begin
         for Index in Entries'Range loop
            if Entries (Index).In_Use
              and then Entries (Index).Registered_ID = Client_ID
            then
               Entries (Index).In_Use := False;
               Entries (Index).Registered_ID := 0;
               Entries (Index).Registered_Socket := null;
               exit;
            end if;
         end loop;
      end Unregister;

      function Find (Client_ID : Unsigned_16) return Socket_Access is
      begin
         for Index in Entries'Range loop
            if Entries (Index).In_Use
              and then Entries (Index).Registered_ID = Client_ID
            then
               return Entries (Index).Registered_Socket;
            end if;
         end loop;

         return null;
      end Find;
   end Client_Registry;

   Registry : Client_Registry;

   task type Client_Handler is
      entry Start (Accepted_Socket : Socket_Access);
   end Client_Handler;

   type Client_Handler_Access is access Client_Handler;

   task body Client_Handler is
      Current_Socket : Socket_Access := null;
      Current_ID     : Unsigned_16 := 0;
   begin
      loop
         accept Start (Accepted_Socket : Socket_Access) do
            Current_Socket := Accepted_Socket;
         end Start;

         declare
            Channel : Stream_Access := Stream (Current_Socket.all);
         begin
            loop
               declare
                  Incoming_Message : Full_Message;
                  Receiver_Socket  : Socket_Access;
                  Payload_Length   : Unsigned_16;
               begin
                  Read_Header
                    (Incoming_Message.Message_Header,
                     Channel,
                     Incoming_Message.Status);

                  if Incoming_Message.Status /= Ok then
                     exit;
                  end if;

                  Payload_Length :=
                    Incoming_Message.Message_Header.Message_Length;
                  Current_ID := Incoming_Message.Message_Header.Sender_ID;
                  Registry.Register (Current_ID, Current_Socket);

                  if Payload_Length = 0 then
                     Put_Line
                       ("Registered client"
                        & Unsigned_16'Image
                            (Incoming_Message.Message_Header.Sender_ID));
                  else
                     declare
                        Payload_Size : constant Positive :=
                          Positive (Payload_Length);
                        Payload      : byte_array (1 .. Payload_Size);
                     begin
                        Read_Payload
                          (Payload,
                           Payload_Length,
                           Channel,
                           Incoming_Message.Status);

                        if Incoming_Message.Status /= Ok then
                           exit;
                        end if;

                        Put_Line
                          ("Message from"
                           & Unsigned_16'Image
                               (Incoming_Message.Message_Header.Sender_ID)
                           & " to"
                           & Unsigned_16'Image
                               (Incoming_Message.Message_Header.Receiver_ID));

                        Receiver_Socket :=
                          Registry.Find
                            (Incoming_Message.Message_Header.Receiver_ID);
                        if Receiver_Socket /= null then
                           Write_Message
                             (Incoming_Message.Message_Header,
                              Payload,
                              Stream (Receiver_Socket.all),
                              Incoming_Message.Status);

                           if Incoming_Message.Status = Ok then
                              Put_Line ("Forwarded to receiver.");
                           end if;
                        else
                           Put_Line ("Receiver not connected.");
                        end if;
                     end;
                  end if;
               exception
                  when others =>
                     exit;
               end;
            end loop;
         end;

         if Current_ID /= 0 then
            Registry.Unregister (Current_ID);
            Current_ID := 0;
         end if;

         if Current_Socket /= null then
            Close_Socket (Current_Socket.all);
         end if;
      end loop;
   end Client_Handler;

   Server_Socket           : Socket_Type;
   Client_Address, Address : Sock_Addr_Type;
   Client_Socket           : Socket_Access;

begin
   Address.Addr := Inet_Addr ("127.0.0.1");
   Address.Port := 12345;

   Create_Socket (Server_Socket);
   Set_Socket_Option (Server_Socket, Socket_Level, (Reuse_Address, True));
   Bind_Socket (Server_Socket, Address);
   Listen_Socket (Server_Socket);

   Put_Line
     ("Listening on: "
      & Image (Address.Addr)
      & " Port: "
      & Address.Port'Image);

   loop
      Client_Socket := new Socket_Type;
      Accept_Socket (Server_Socket, Client_Socket.all, Client_Address);
      Put_Line ("Client Connected: " & Image (Client_Address.Addr));

      declare
         Handler : Client_Handler_Access := new Client_Handler;
      begin
         Handler.Start (Client_Socket);
      end;
   end loop;
end server;
