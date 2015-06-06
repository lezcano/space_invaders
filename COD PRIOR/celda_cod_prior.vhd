library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity celda_cod_prior is
	port(
		X: in std_logic;
		pos_ant: in std_logic_vector (small_int -1 downto 0);
		est_ant: in estado_cod;
		
		pos_act: out std_logic_vector (small_int -1 downto 0);
		est_sig: out estado_cod
	);
end celda_cod_prior;

architecture celda_cod_prior_arch of celda_cod_prior is

begin
	-- La posición que nos pasan si es encontrado es la de la celda en la que esta
	-- Si el anterior no era encontrado nos pasan la celda en la que estamos.
	pos_act <= 	pos_ant when est_ant = ENCONTR or X = '1' else
					pos_ant + 1;
					
	est_sig <= 	ENCONTR when est_ant = ENCONTR or X = '1' else
					NOENCONTR;

end celda_cod_prior_arch;

