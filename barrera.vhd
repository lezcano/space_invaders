library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity barrera is
	port(
			clk: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posición del puntero horizontal 
			vcnt: in vertical_counter;				-- Posición del puntero vertical	
			colision_barrera: in std_logic;
			inicio_v : in vertical_counter;
			inicio_h : in horizontal_counter;
			estado_juego: in estados_juego;
			tam_barrera_x : in integer;
			tam_barrera_y : in integer;

			
			pintar_barrera: out std_logic;			-- Pintar barrera
			color: out color_rgb					-- Color de la barrera
	);
end barrera;

architecture Behavioral of barrera is

	--constant tam_barrera_x: integer := 64;
	--constant tam_barrera_y: integer := 32;
	--constant inicio_v: vertical_counter := conv_std_logic_vector(250, tam_v_counter);
	--constant inicio_h: horizontal_counter := conv_std_logic_vector(120, tam_h_counter);
	constant color_barrera: color_rgb := "000111000"; 
	--constant filas_barrera : integer := 8;
	--constant columnas_barrera : integer := 16;
	type matriz_tam_barrera is array (filas_barrera - 1 downto 0) of std_logic_vector (columnas_barrera - 1 downto 0);
	
	-- Señales de posicion en matriz
	signal dif_x : horizontal_counter;
	signal dif_y : vertical_counter;
	
	-- Señales matriz barrera
	signal sig_activos : matriz_tam_barrera;
	signal activos: matriz_tam_barrera; -- debug

	-- Señales color
	signal color_a_pintar: color_rgb;
	

begin
color <= color_barrera;

	dif_x <= hcnt - inicio_h;
	dif_y <= vcnt - inicio_v;

	main_process: process (reset)
	begin
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
		and estado_juego /= YOUR_LEVEL)then
			activos <= (others => (others => '1'));
		elsif clk'event and clk = '1' then
			activos <= sig_activos;
		end if;
	end process main_process;	
	
	colision: process (colision_barrera, activos)
	begin	
		sig_activos <= activos; --Elimina latches
		if colision_barrera = '1' then
			sig_activos (conv_integer(dif_y(3)))(conv_integer(dif_x(4 downto 3))) <= '0';
		else 
			sig_activos <= activos;
		end if;
	end process colision;
	
	
	pintar: process(hcnt, vcnt) 
	begin
		pintar_barrera <= '0';
		if hcnt > inicio_h and hcnt < inicio_h + tam_barrera_x then
			if vcnt > inicio_v and vcnt < inicio_v + tam_barrera_y then
				if(activos(conv_integer(dif_y(3)))(conv_integer(dif_x(4 downto 3))) = '1') then
					pintar_barrera <= '1';
				end if;
			end if;
		end if;
	end process pintar;
end Behavioral;