LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE test OF testbench IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset_n : STD_LOGIC := '0';
    SIGNAL cipher_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL message : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL encrypted_text : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL deciphered_text : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    -- Instantiate LFSR
    codec_inst : ENTITY work.enc_dec_top
        PORT MAP(
            in_message => message,
            reset => reset_n,
            clock => clk,
            out_encrypted => encrypted_text,
            out_deciphered => deciphered_text
        );

    -- Clock generation
    clk <= NOT clk AFTER 5 ns;

    -- Test stimulus
    PROCESS
    BEGIN
        -- Hold in reset for initial cycles
        -- Expected: cipher_out held at x"A5A5" (init value); cipher_text = x"A5" XOR x"00" = x"A5"
        reset_n <= '0';
        message <= x"00";
        WAIT FOR 20 ns;

        -- Release reset
        -- Expected: LFSR begins shifting and produces new keystream each clock; cipher_text evolves
        reset_n <= '1';
        message <= x"AA";
        WAIT FOR 20 ns;

        -- Change message
        -- Expected: LFSR continues shifting; cipher_text = cipher_out(7:0) XOR x"55"
        message <= x"55";
        WAIT FOR 20 ns;

        -- Change message again
        -- Expected: LFSR continues shifting; cipher_text = cipher_out(7:0) XOR x"FF"
        message <= x"FF";
        WAIT FOR 20 ns;

        -- Change message
        -- Expected: LFSR continues shifting; cipher_text = cipher_out(7:0) XOR x"AA"
        message <= x"AA";
        WAIT FOR 20 ns;

        -- End test stimulus and idle
        WAIT;
    END PROCESS;

END test;