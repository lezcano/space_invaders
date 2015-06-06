library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cod_prior_matriz is
	port (
		matriz: in matriz_tam_marc;
		
		encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
		pos_x: out t_small_int;
		pos_y: out t_small_int
	);

end cod_prior_matriz;

architecture cod_prior_matriz_arch of cod_prior_matriz is

	component cod_prior is
		generic (
			width: integer := 8
		);
		port (
			arr: in std_logic_vector (width-1 downto 0);
			
			encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
			pos: out std_logic_vector (small_int-1 downto 0)
		);
	end component cod_prior;
	
	type v_small_int_alto is array (filas_marc-1 downto 0) of t_small_int;
	
	signal vector_pos_x: v_small_int_alto;
	signal pos_y_out: t_small_int;
	signal encontrados: std_logic_vector (filas_marc-1 downto 0);

begin

		-- Cablea todos los codificadores de prioridad
		filas: for i in 0 to filas_marc-1 generate
			ured: cod_prior 	generic map (width => columnas_marc)
									port map (matriz (i), encontrados(i), vector_pos_x (i));
		end generate filas;
		
		u_prior_ppal: cod_prior generic map (width => filas_marc)
										port map (encontrados, encontrado, pos_y_out);
		pos_y <= pos_y_out;
		pos_x <= vector_pos_x (conv_integer (pos_y_out));		


end cod_prior_matriz_arch;

