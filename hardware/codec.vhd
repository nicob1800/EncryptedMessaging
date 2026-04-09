LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY codec IS
    PORT (
        cipher : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        message : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        out_text : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- this is the encrypted/deciphered message
    );
END codec;

ARCHITECTURE codec_arch OF codec IS
BEGIN

    out_text <= cipher(7 DOWNTO 0) XOR message;

END codec_arch;