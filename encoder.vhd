ENTITY encoder IS
    PORT (
        cipher : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        message : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        cipher_text : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END encoder;

ARCHITECTURE encoder_arch OF encoder IS
BEGIN

    cipher_text <= cipher(7 DOWNTO 0) XOR message;

END encoder_arch;