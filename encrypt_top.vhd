LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY encrypt_top IS
    PORT (
        message : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        treset_n : IN STD_LOGIC;
        tclk : IN STD_LOGIC;
        encrypted : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END encrypt_top;

ARCHITECTURE encrypt_top_arch OF encrypt_top IS

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
    u_encoder : ENTITY work.encoder(encoder_arch)
        PORT MAP(
            cipher => cipher_wire,
            message => message,
            cipher_text => encrypted_message_wire
        );
END
END encrypt_top_arch;