with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

procedure server is
   Client_Socket, Server_Socket : Socket_Type;

   Client_Address, Address : Sock_Addr_Type;
   Channel                 : Stream_Access;

begin

   Address.Addr := Inet_Addr ("127.0.0.1");
   Address.Port := 12345;

   Create_Socket (Server_Socket); --Initialize server socket
   Set_Socket_Option (Server_Socket, Socket_Level, (Reuse_Address, True));
   Bind_Socket (Server_Socket, Address);
   Listen_Socket (Server_Socket);

   Put_Line
     ("Listening on: "
      & Image (Address.Addr)
      & " Port: "
      & Address.Port'image);
   loop
      begin
         Accept_Socket (Server_Socket, Client_Socket, Client_Address);
         loop
            begin
               declare
                  length          : Integer := Message'Length;
                  message_to_send : String := Message;
               begin

               end;
            end;
         end loop;
      end;
   end loop;
end;
