LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY enc_dec_top IS
    PORT (
        in_message : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        reset : IN STD_LOGIC;
        clock : IN STD_LOGIC;
        out_encrypted : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        out_deciphered : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END enc_dec_top;

ARCHITECTURE enc_dec_top_arch OF enc_dec_top IS
    --encoder to decoder
    SIGNAL enc_to_dec : STD_LOGIC_VECTOR(7 DOWNTO 0);

    --
BEGIN
    out_encrypted <= enc_to_dec;
    u_encoder : ENTITY work.codec_top(codec_top_arch)
        PORT MAP(
            tmessage => in_message,
            treset_n => reset,
            tclk => clock,
            encrypted => enc_to_dec
        );

    u_decoder : ENTITY work.codec_top(codec_top_arch)
        PORT MAP(
            tmessage => enc_to_dec,
            treset_n => reset,
            tclk => clock,
            encrypted => out_deciphered
        );
END enc_dec_top_arch;