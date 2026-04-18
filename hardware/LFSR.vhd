LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LFSR IS
    PORT (
        reset_n : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        cipher_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --This is the cipher for the encoder
    );

END LFSR;

ARCHITECTURE LFSR_ARCH OF LFSR IS
    SIGNAL temp : STD_LOGIC;
    SIGNAL to_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"A5A5";

BEGIN
    temp <= to_out(10) XOR (to_out(12) XOR (to_out(14) XOR to_out(15)));
    cipher_out <= to_out;

    PROCESS (clk)

    BEGIN
        IF rising_edge(clk) THEN
            IF reset_n = '0' THEN
                to_out <= x"A5A5";
            ELSIF enable = '1' THEN
                to_out <= temp & to_out(15 DOWNTO 1);
            ELSE
                to_out <= to_out;
            END IF;
        END IF;
    END PROCESS;

END LFSR_ARCH;