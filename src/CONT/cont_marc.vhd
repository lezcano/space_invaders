library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;

entity cont_marc is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC;
        clk_salida: out STD_LOGIC 
    );
end cont_marc;

architecture divisor_arch of cont_marc is
 SIGNAL cuenta: std_logic_vector(3 downto 0);
 SIGNAL clk_aux, clk: std_logic;
  
  begin

clk<=clk_entrada; 
clk_salida<=clk_aux;
  contador:
  PROCESS(reset, clk)
  BEGIN
    IF (reset='1') THEN
      cuenta<= (OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
      IF (cuenta="1111") THEN
      	clk_aux <= not clk_aux;
        cuenta<= (OTHERS=>'0');
      ELSE
        cuenta <= cuenta+'1';
      END IF;
    END IF;
  END PROCESS contador;

end divisor_arch;
