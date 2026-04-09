LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY encoder IS
    PORT (
        cipher : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        message : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        encrypted_text : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- this is the encrypted message
    );
END encoder;

ARCHITECTURE encoder_arch OF encoder IS
BEGIN

    encrypted_text <= cipher(7 DOWNTO 0) XOR message;

END encoder_arch;