library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tipos.all;

entity cod_prior is
	generic (
		width: integer := 8
	);
	port (
		arr: in std_logic_vector (width-1 downto 0);
		
		encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
		pos: out std_logic_vector (small_int-1 downto 0)
	);
end cod_prior;

architecture cod_prior_arch of cod_prior is

	component celda_cod_prior is
		port(
			X: in std_logic;
			pos_ant: in std_logic_vector (small_int -1 downto 0);
			est_ant: in estado_cod;
			
			pos_act: out std_logic_vector (small_int -1 downto 0);
			est_sig: out estado_cod
		);
	end component celda_cod_prior;

	type v_small_int is array (width-1 downto 0) of std_logic_vector (small_int -1 downto 0);
	type v_estados is array (width-1 downto 0) of estado_cod;
	
	signal v_pos: v_small_int;
	signal v_est: v_estados;

begin
	c0: celda_cod_prior port map (arr(0), (others => '0'), NOENCONTR, v_pos(0), v_est(0));
	gen_celdas: for i in 1 to width-1 generate
		ck: celda_cod_prior port map (arr(i), v_pos(i-1), v_est(i-1), v_pos(i), v_est(i));
	end generate gen_celdas;
	
	encontrado <= 	'1' when v_est(width-1) = ENCONTR else
						'0';
	pos <= v_pos (width-1);

end cod_prior_arch;

