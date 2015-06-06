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

-----------------------------------------------
--
--  Estructura del Codificador de Prioridad:
--
--	Ejemplo con filas_marc = 4, columnas_marc = 7
--	
--	0	1	0	0	1	1	1
--	0	1	1	0	1	0	1
--	0	0	1	0	0	0	1
--	0	1	0	0	0	0	0
--	-------------------------
--	
--	En la matriz traspuesta cada columna es un vector y la matriz es un vector de columnas.
--	Matriz traspuesta:
--	matriz_tr = {
--					{0, 0, 0, 0}
--					{1, 1, 0, 1}
--					{0, 1, 1, 0}
--					{0, 0, 0, 0}
--					{1, 1, 0, 0}
--					{1, 0, 0 ,0}
--					{1, 1, 1, 0}
--				}
--	La matriz es de vectores downto, con lo que la matriz_tr (0, 0)  = 0 (el dígito de abajo a la derecha).
--	
--	Los valores que sacará para esta configuración serán:
--	col_activa_iz = 1
--	col_activa_der = 6
--	num_col_activ = 5
--  primer_activ = {1, 3, 2, 0, 1, 0, 0}  => Si esta desactivado devuelve 0
--
-------------------------------------------
	


entity cod_prior_matriz_marc is
	port (
		matriz: in matriz_tam_marc;
		num_disp: in t_small_int;
		
		col_activa_iz: out t_small_int;
		col_activa_der: out t_small_int;
		num_col_activ: out t_small_int;
		primer_activ: out v_small_int_columnas;
		marc_disp: out t_small_int
		
	);
end cod_prior_matriz_marc;

architecture cod_prior_matriz_marc_arch of cod_prior_matriz_marc is

	component cod_prior_marc is
		generic (
			width: integer := 8
		);
		port (
			arr: in std_logic_vector (width-1 downto 0);
			num_disp: in t_small_int;
			
			encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
			pos_primer: out t_small_int;
			pos_ult: out t_small_int;
			num_activ: out t_small_int;
			pos_disp: out t_small_int
		);
	end component cod_prior_marc;
	
	type matriz_tam_marc_tr is array (columnas_marc-1 downto 0) of std_logic_vector (filas_marc -1 downto 0) ; -- Matriz Traspuesta
	
	signal matriz_tr: matriz_tam_marc_tr;
	
	signal encontrados: std_logic_vector (columnas_marc - 1 downto 0);

begin

	-- Cablea todos los codificadores de prioridad
		filas: for i in 0 to columnas_marc-1 generate
			ured: cod_prior_marc generic map (width => filas_marc)
										port map 
										(arr => matriz_tr (i),
										num_disp => num_disp, -- no se va a utilizar aqui
										
										encontrado => encontrados (i),
										pos_primer => primer_activ (i),
										pos_ult => open,
										num_activ => open,
										pos_disp => open);
		end generate filas;
		
		u_prior_ppal: cod_prior_marc generic map (width => columnas_marc)
											port map 
											(arr => encontrados,
											num_disp => num_disp,
											
											encontrado => open,
											pos_primer => col_activa_der,
											pos_ult => col_activa_iz,
											num_activ => num_col_activ, -- Esta primero la derecha y luego la izda porque va de derecha a izda la matriz
											pos_disp=> marc_disp
											); 


	main: process (matriz)
	begin
			filas: for i in 0 to filas_marc - 1 loop
				col: for j in 0 to columnas_marc - 1 loop
					matriz_tr (j) (i) <= matriz (i) (j); -- Crea una matriz como un array de filas en vez de como un array de columnas que es el imput.
				end loop col;
			end loop filas;
	end process;
			
	

end cod_prior_matriz_marc_arch;
