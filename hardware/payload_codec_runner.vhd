LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY std;
USE std.textio.ALL;

ENTITY payload_codec_runner IS
END payload_codec_runner;

ARCHITECTURE sim OF payload_codec_runner IS
    CONSTANT Input_File_Name : STRING := "payload_to_enc.bin";
    CONSTANT Output_File_Name : STRING := "enc_to_payload.bin";

    TYPE payload_buffer_t IS ARRAY (NATURAL RANGE 0 TO 65534) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset_n : STD_LOGIC := '0';
    SIGNAL start_msg : STD_LOGIC := '0';
    SIGNAL counter_value : unsigned(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tenable : STD_LOGIC := '0';
    SIGNAL message_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL encoded_out : STD_LOGIC_VECTOR(7 DOWNTO 0);

    FUNCTION Hex_Value (Ch : CHARACTER) RETURN NATURAL IS
    BEGIN
        CASE Ch IS
            WHEN '0' => RETURN 0;
            WHEN '1' => RETURN 1;
            WHEN '2' => RETURN 2;
            WHEN '3' => RETURN 3;
            WHEN '4' => RETURN 4;
            WHEN '5' => RETURN 5;
            WHEN '6' => RETURN 6;
            WHEN '7' => RETURN 7;
            WHEN '8' => RETURN 8;
            WHEN '9' => RETURN 9;
            WHEN 'A' | 'a' => RETURN 10;
            WHEN 'B' | 'b' => RETURN 11;
            WHEN 'C' | 'c' => RETURN 12;
            WHEN 'D' | 'd' => RETURN 13;
            WHEN 'E' | 'e' => RETURN 14;
            WHEN 'F' | 'f' => RETURN 15;
            WHEN OTHERS => RETURN 0;
        END CASE;
    END Hex_Value;

    FUNCTION To_Hex_Char (Value : NATURAL) RETURN CHARACTER IS
    BEGIN
        IF Value < 10 THEN
            RETURN CHARACTER'Val (CHARACTER'Pos ('0') + Value);
        ELSE
            RETURN CHARACTER'Val (CHARACTER'Pos ('A') + (Value - 10));
        END IF;
    END To_Hex_Char;

    FUNCTION To_Hex_String_4 (Value : NATURAL) RETURN STRING IS
        VARIABLE Result : STRING (1 TO 4);
    BEGIN
        Result (1) := To_Hex_Char (Value / 4096);
        Result (2) := To_Hex_Char ((Value / 256) MOD 16);
        Result (3) := To_Hex_Char ((Value / 16) MOD 16);
        Result (4) := To_Hex_Char (Value MOD 16);
        RETURN Result;
    END To_Hex_String_4;

    FUNCTION To_Hex_String_2 (Value : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STRING IS
        VARIABLE Result : STRING (1 TO 2);
    BEGIN
        Result (1) := To_Hex_Char (to_integer (unsigned (Value (7 DOWNTO 4))));
        Result (2) := To_Hex_Char (to_integer (unsigned (Value (3 DOWNTO 0))));
        RETURN Result;
    END To_Hex_String_2;

BEGIN
    clk <= NOT clk AFTER 5 ns;

    u_codec : ENTITY work.codec_top(codec_top_arch)
        PORT MAP(
            tmessage => message_in,
            treset_n => reset_n,
            tclk => clk,
            start_msg => start_msg,
            counter_value => counter_value,
            tenable => tenable,
            encrypted => encoded_out
        );

    PROCESS
        FILE input_file : text;
        FILE output_file : text;
        VARIABLE file_status : file_open_status;
        VARIABLE input_line : line;
        VARIABLE output_line : line;
        VARIABLE header_text : STRING (1 TO 4);
        VARIABLE byte_text : STRING (1 TO 2);
        VARIABLE payload_mem : payload_buffer_t;
        VARIABLE count : NATURAL := 0;
        VARIABLE payload_len : NATURAL := 0;
        VARIABLE counter_int : NATURAL := 0;
        VARIABLE counter_slv : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE byte_slv : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE input_ok : BOOLEAN;
    BEGIN
        reset_n <= '0';
        WAIT FOR 20 ns;
        reset_n <= '1';

        LOOP
            -- Wait until the previous response has been consumed.
            file_open(file_status, output_file, Output_File_Name, read_mode);
            IF file_status = open_ok THEN
                file_close(output_file);
                WAIT FOR 10 ns;
                NEXT;
            END IF;

            -- Wait for the next request file.
            file_open(file_status, input_file, Input_File_Name, read_mode);
            IF file_status /= open_ok THEN
                WAIT FOR 10 ns;
                NEXT;
            END IF;

            count := 0;
            payload_len := 0;
            counter_int := 0;
            input_ok := TRUE;

            IF endfile(input_file) THEN
                input_ok := FALSE;
            ELSE
                readline(input_file, input_line);
                IF input_line'length < 4 THEN
                    input_ok := FALSE;
                ELSE
                    header_text := input_line.ALL (1 TO 4);
                    counter_slv(15 DOWNTO 12) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(header_text(1)), 4));
                    counter_slv(11 DOWNTO 8) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(header_text(2)), 4));
                    counter_slv(7 DOWNTO 4) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(header_text(3)), 4));
                    counter_slv(3 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(header_text(4)), 4));
                    counter_value <= unsigned(counter_slv);
                    counter_int := to_integer(unsigned(counter_slv));
                END IF;
            END IF;

            IF input_ok THEN
                IF endfile(input_file) THEN
                    input_ok := FALSE;
                ELSE
                    readline(input_file, input_line);
                    IF input_line'length < 4 THEN
                        input_ok := FALSE;
                    ELSE
                        header_text := input_line.ALL (1 TO 4);
                        payload_len := Hex_Value(header_text(1)) * 4096
                            + Hex_Value(header_text(2)) * 256
                            + Hex_Value(header_text(3)) * 16
                            + Hex_Value(header_text(4));
                    END IF;
                END IF;
            END IF;

            WHILE input_ok AND count < payload_len LOOP
                IF endfile(input_file) THEN
                    input_ok := FALSE;
                ELSE
                    readline(input_file, input_line);
                    IF input_line'length < 2 THEN
                        input_ok := FALSE;
                    ELSE
                        byte_text := input_line.ALL (1 TO 2);
                        byte_slv(7 DOWNTO 4) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(byte_text(1)), 4));
                        byte_slv(3 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(Hex_Value(byte_text(2)), 4));
                        IF count > payload_mem'high THEN
                            input_ok := FALSE;
                        ELSE
                            payload_mem(count) := byte_slv;
                            count := count + 1;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            file_close(input_file);

            IF NOT input_ok THEN
                WAIT FOR 10 ns;
                NEXT;
            END IF;

            REPORT "payload_codec_runner: counter="
                & INTEGER'IMAGE (counter_int)
                & " length="
                & INTEGER'IMAGE (payload_len);

            start_msg <= '1';
            WAIT FOR 10 ns;
            start_msg <= '0';

            FOR i IN 1 TO counter_int LOOP
                WAIT FOR 10 ns;
            END LOOP;

            FOR i IN 0 TO count - 1 LOOP
                message_in <= payload_mem(i);
                tenable <= '1';
                WAIT FOR 10 ns;
                tenable <= '0';
                WAIT FOR 10 ns;
                payload_mem(i) := encoded_out;
            END LOOP;

            file_open(file_status, output_file, Output_File_Name, write_mode);
            IF file_status /= open_ok THEN
                WAIT FOR 10 ns;
                NEXT;
            END IF;

            write(output_line, To_Hex_String_4(counter_int));
            writeline(output_file, output_line);

            write(output_line, To_Hex_String_4(count));
            writeline(output_file, output_line);

            FOR i IN 0 TO count - 1 LOOP
                write(output_line, To_Hex_String_2(payload_mem(i)));
                writeline(output_file, output_line);
            END LOOP;

            file_close(output_file);

            REPORT "payload_codec_runner: wrote "
                & INTEGER'IMAGE (count)
                & " byte(s) to "
                & Output_File_Name;
        END LOOP;
    END PROCESS;
END sim;