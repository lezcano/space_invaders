-- Implementa un conjunto de disparos

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;


entity laser_array is
	port(	
			clk_fps: in std_logic;
			clk_main: in std_logic;	
			clk_vga: in std_logic;
			reset: in std_logic;			
			hcnt: in horizontal_counter; 		-- Posici贸n del puntero horizontal 
			vcnt: in vertical_counter;			-- Posici贸n del puntero vertical
			estado_juego: in estados_juego;
			activa_laser: in std_logic;	-- Pide activar nuevo disparo
			pos_nave_x: in horizontal_counter;	-- Posici贸n de la nave al ser activado
			pos_nave_y: in vertical_counter;	-- Posici贸n de la nave al ser activado
			colision_laser: in std_logic;
			
			debug: out std_logic_vector (8 downto 0);
			pinta_laser: out std_logic;				-- Pintar laser
			color_laser: out color_rgb				-- Color del que pintar laser

		);
end laser_array;

architecture laser_array_arch of laser_array is
	
	component laser is
	port(	
			clk_fps: in std_logic;		
			clk_vga: in std_logic;			
			reset: in std_logic;			
			hcnt: in horizontal_counter; 		-- Posici髇 del puntero horizontal 
			vcnt: in vertical_counter;			-- Posici髇 del puntero vertical
			estado_juego: in estados_juego;
			activa_laser: in std_logic;		-- Pide activar el laser
			desactiva_laser: in std_logic;	--Pide desactivar el laser
			pos_ini_x: in horizontal_counter;	-- Posici髇 inicial del laser al ser activado
			pos_ini_y: in vertical_counter;
			laser_speed_x: in horizontal_counter; --tienen que ser de este tipo para que sumar un negativo en C1 funcione bien
			laser_speed_y: in vertical_counter;
			
			pinta_laser: out std_logic;		-- Pintar laser
			color: out color_rgb				-- Color del que pintar laser
			
		);
	end component laser;
	
	component cont_retardo_laser is 
    port (
        reset: in STD_LOGIC;
		  reinicia: in std_logic;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
	end component cont_retardo_laser;
	
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
		
	constant retardo: integer := 4; 			-- N煤mero de frames necesarios entre disparos
	constant num_max_disparos: integer := 8; 	-- N煤mero m谩ximo de disparos en pantalla (por exceso)
	
	type matriz_colores is array (num_max_disparos downto 0) of color_rgb;
	
	signal puede_disp: std_logic;
	signal sig_puede_disp: std_logic;
	
	signal activa_disp: std_logic_vector (num_max_disparos downto 0);		-- Array principal que activa los disparos. Implementado como un array circular
	signal sig_activa_disp: std_logic_vector (num_max_disparos downto 0);
	signal desactiva_disp: std_logic_vector (num_max_disparos downto 0);

	signal pos_libre: std_logic_vector (small_int-1 downto 0);
	signal sig_pos_libre: std_logic_vector (small_int-1 downto 0);
	--signal ant_pos_libre: std_logic_vector (small_int -1 downto 0);	-- Posici髇 que estuvo libre en el anterior ciclo
	
	signal clock_retardo: std_logic;
	
	signal hay_que_pintar: std_logic_vector (num_max_disparos downto 0);
	signal color_a_pintar: matriz_colores; 
	
	-- Variables codificador. Cambiar
	signal pos_a_pintar: std_logic_vector (small_int-1 downto 0);
	signal hay_que_pintar_uno: std_logic;
	
	signal activo: std_logic_vector (num_max_disparos downto 0);


begin
	-- Cableado de los lasers
	gen_lasers: for i in 0 to num_max_disparos generate
		l: laser port map
			(
			clk_fps => clk_fps, 
			clk_vga => clk_vga,					
			reset => reset,			
			hcnt => hcnt,
			vcnt => vcnt,
			estado_juego => estado_juego, 
			activa_laser => activa_disp(i),
			desactiva_laser => desactiva_disp(i),
			pos_ini_x => pos_nave_x,
			pos_ini_y => pos_nave_y,
			laser_speed_x => (others => '0'),
			laser_speed_y => conv_std_logic_vector(4, tam_v_counter),
			
			pinta_laser => hay_que_pintar (i),
			color =>  color_a_pintar (i)
			);
		
	end generate gen_lasers;

	
	cont_ret: cont_retardo_laser port map (reset, puede_disp, clk_fps, clock_retardo);
	
	-- Cablea el codificador de los disparos
	codificador_pintar: cod_prior 	
									generic map (width => num_max_disparos + 1) 
									port map(hay_que_pintar, hay_que_pintar_uno, pos_a_pintar);

	pinta_laser <= hay_que_pintar_uno;


	main_process: process (clk_vga, reset, estado_juego)
	begin 
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2 and
			estado_juego /= YOUR_LEVEL)  then
			puede_disp <= '1';
			activa_disp <= (others => '0');
			pos_libre <= (others => '0');
			
		elsif (clk_vga'event and clk_vga='1') then
			puede_disp <= sig_puede_disp;
			pos_libre <= sig_pos_libre;
			activa_disp <= sig_activa_disp;
		end if;
		
	end process main_process;
	
	-- Actualiza la posici髇 libre del array
	next_pos_libre: process (activa_laser, puede_disp, pos_libre)
	begin
		if activa_laser = '1'  and puede_disp = '1' then   
			if pos_libre = num_max_disparos then
				sig_pos_libre <= (others => '0');
			else
				sig_pos_libre <= pos_libre + 1;
			end if;
		else -- Elimina Latches
			sig_pos_libre <= pos_libre;		
		end if;
	end process next_pos_libre;
	
	-- Actualiza puede disparar
	proc_puede_disp: process (activa_laser, puede_disp, clock_retardo)
	begin
		if puede_disp = '0' then
			if clock_retardo'event and clock_retardo = '1' then
				sig_puede_disp <= '1';
			end if;
		else
			if activa_laser = '1' then
				sig_puede_disp <= '0';
			else
				sig_puede_disp <= puede_disp;
			end if;
		end if;
	end process proc_puede_disp;
	
	-- Actualiza que disparo se ha de pedir que dispare
	proc_activa_disp: process (activa_laser, puede_disp, sig_pos_libre, activa_disp)
	begin
		
		
		sig_activa_disp <= activa_disp; -- Elimina latches
		
		if pos_libre = 0 then	
			sig_activa_disp (num_max_disparos) <= '0';
		else
			sig_activa_disp (conv_integer(pos_libre)- 1)  <= '0';
		end if;
		
		if puede_disp = '1' then
			-- Desactiva la anterior peticion de activa laser
			
			
			-- Si vuelven a pedir que active laser, lo activa
			-- Probar sustituir esto por: sig_activa_disp (conv_integer(pos_libre)) <= activa_laser;
			if activa_laser = '1' then
				sig_activa_disp (conv_integer(pos_libre)) <= '1';	
			else
				sig_activa_disp (conv_integer(pos_libre)) <= '0';	-- Elimina Latches
			end if;
		end if;
	end process proc_activa_disp;
	
	colision: process (colision_laser, desactiva_disp)
	begin
		desactiva_disp <= (others => '0');
		if colision_laser = '1' then
			desactiva_disp(conv_integer(pos_a_pintar)) <= '1';
		end if;
	end process colision;
	
	disparo_a_pintar: process (hay_que_pintar_uno, color_a_pintar)
	begin
		if hay_que_pintar_uno = '1' then
			color_laser <= color_a_pintar (conv_integer(pos_a_pintar));
		else
			color_laser <= (others => '0'); -- Elimina Latches
		end if;
	end process disparo_a_pintar;
	
end laser_array_arch;