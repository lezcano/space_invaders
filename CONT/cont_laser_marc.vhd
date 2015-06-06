library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;

entity cont_laser_marc is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        ret_activa_laser: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end cont_laser_marc;

architecture divisor_arch of cont_laser_marc is
 SIGNAL cuenta: std_logic_vector(7 downto 0);
 SIGNAL clk_aux, clk: std_logic;
  
  begin

clk<=clk_entrada; 
ret_activa_laser<=clk_aux;
  contador:
  PROCESS(reset, clk)
  BEGIN
    IF (reset='1') THEN
      cuenta<= (OTHERS=>'0');
    ELSIF(clk'EVENT AND clk='1') THEN
      IF (cuenta="1111111") THEN 
      	clk_aux <= not clk_aux;
        cuenta<= (OTHERS=>'0');
      ELSE
        cuenta <= cuenta+'1';
      END IF;
    END IF;
  END PROCESS contador;

end divisor_arch;
