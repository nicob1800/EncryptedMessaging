ENTITY LFSR IS
    PORT (
        reset_n : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        cipher_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );

END LFSR;

ARCHITECTURE LFSR_ARCH OF LFSR IS
    SIGNAL temp : STD_LOGIC;
    SIGNAL to_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    temp <= to_out(10) XOR (to_out(12) XOR (to_out(14) XOR to_out(15)));
    PROCESS (clk, reset_n)
    BEGIN
        IF rising_edge(clk) THEN
            IF NOT reset_n THEN
                to_out <= x"A5A5";
            ELSE
                to_out <= temp & to_out(15 : 1);
            END IF;
            cipher_out <= to_out;
        END IF;
    END PROCESS;
END

END LFSR_ARCH;