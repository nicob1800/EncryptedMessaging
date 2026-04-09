LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY codec_top IS
    PORT (
        tmessage : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        treset_n : IN STD_LOGIC;
        tclk : IN STD_LOGIC;
        encrypted : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END codec_top;

ARCHITECTURE codec_top_arch OF codec_top IS

    SIGNAL cipher_wire : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL encrypted_message_wire : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    encrypted <= encrypted_message_wire;

    u_LFSR : ENTITY work.LFSR(LFSR_ARCH)
        PORT MAP(
            clk => tclk,
            reset_n => treset_n,
            cipher_out => cipher_wire
        );
    u_codec : ENTITY work.codec(codec_arch)
        PORT MAP(
            cipher => cipher_wire,
            message => tmessage,
            out_text => encrypted_message_wire
        );
END codec_top_arch;