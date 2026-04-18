LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE test OF testbench IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset_n : STD_LOGIC := '0';
    SIGNAL start_msg : STD_LOGIC := '0';
    SIGNAL counter_value : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL enable : STD_LOGIC := '0';
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
            start_msg => start_msg,
            counter_value => counter_value,
            enable => enable,
            out_encrypted => encrypted_text,
            out_deciphered => deciphered_text
        );

    -- Clock generation
    clk <= NOT clk AFTER 5 ns;

    -- Test stimulus
    PROCESS
    BEGIN
        -- Hold in reset for initial cycles
        reset_n <= '0';
        start_msg <= '0';
        counter_value <= (OTHERS => '0');
        enable <= '0';
        message <= x"00";
        WAIT FOR 20 ns;

        -- Start a message and pre-run LFSR by 3 cycles before data bytes.
        reset_n <= '1';
        counter_value <= to_unsigned(3, 16);
        start_msg <= '1';
        WAIT FOR 10 ns;
        start_msg <= '0';
        WAIT FOR 40 ns;

        -- Byte-valid pulses after pre-run.
        message <= x"AA";
        enable <= '1';
        WAIT FOR 10 ns;
        enable <= '0';
        WAIT FOR 10 ns;

        -- Next byte: pulse enable for one cycle
        message <= x"55";
        enable <= '1';
        WAIT FOR 10 ns;
        enable <= '0';
        WAIT FOR 10 ns;

        -- Next byte: pulse enable for one cycle
        message <= x"FF";
        enable <= '1';
        WAIT FOR 10 ns;
        enable <= '0';
        WAIT FOR 10 ns;

        -- Next byte: pulse enable for one cycle
        message <= x"AA";
        enable <= '1';
        WAIT FOR 10 ns;
        enable <= '0';
        WAIT FOR 10 ns;

        -- End test stimulus and idle
        WAIT;
    END PROCESS;

END test;