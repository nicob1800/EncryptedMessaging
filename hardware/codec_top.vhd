LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY codec_top IS
    PORT (
        tmessage : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        treset_n : IN STD_LOGIC;
        tclk : IN STD_LOGIC;
        start_msg : IN STD_LOGIC;
        counter_value : IN UNSIGNED(15 DOWNTO 0);
        tenable : IN STD_LOGIC;
        encrypted : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END codec_top;

ARCHITECTURE codec_top_arch OF codec_top IS

    SIGNAL cipher_wire : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL encrypted_message_wire : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL lfsr_enable : STD_LOGIC := '0';
    SIGNAL prerun_active : STD_LOGIC := '0';
    SIGNAL prerun_count : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');

BEGIN
    encrypted <= encrypted_message_wire;

    PROCESS (tclk)
    BEGIN
        IF rising_edge(tclk) THEN
            IF treset_n = '0' THEN
                prerun_active <= '0';
                prerun_count <= (OTHERS => '0');
                lfsr_enable <= '0';
            ELSIF start_msg = '1' THEN
                prerun_count <= counter_value;
                IF counter_value = 0 THEN
                    prerun_active <= '0';
                    lfsr_enable <= tenable;
                ELSE
                    prerun_active <= '1';
                    lfsr_enable <= '0';
                END IF;
            ELSIF prerun_active = '1' THEN
                lfsr_enable <= '1';
                IF prerun_count = 1 THEN
                    prerun_count <= (OTHERS => '0');
                    prerun_active <= '0';
                ELSE
                    prerun_count <= prerun_count - 1;
                END IF;
            ELSE
                lfsr_enable <= tenable;
            END IF;
        END IF;
    END PROCESS;

    u_LFSR : ENTITY work.LFSR(LFSR_ARCH)
        PORT MAP(
            clk => tclk,
            reset_n => treset_n,
            enable => lfsr_enable,
            cipher_out => cipher_wire
        );
    u_codec : ENTITY work.codec(codec_arch)
        PORT MAP(
            cipher => cipher_wire,
            message => tmessage,
            out_text => encrypted_message_wire
        );
END codec_top_arch;