library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity invader_array is
	port(
		clk_fps: in std_logic;
		clk_vga: in std_logic;
		clk_main: in std_logic;
		reset: in std_logic;
		hcnt: in horizontal_counter;
		vcnt: in vertical_counter;
		estado_juego: in estados_juego;
		colision_marc: in std_logic;
		random_i: in t_small_int;
		colision_laser: in std_logic;
		distr_your_lvl: in matriz_id_color;
		set_x: in std_logic_vector (log_columnas_marc-1 downto 0);
		set_y: in std_logic_vector (log_filas_marc-1 downto 0);
		
		
		debug: out std_logic_vector (8 downto 0);
		debug2: out std_logic_vector (6 downto 0);
		debug3: out std_logic_vector (6 downto 0);
		activo_out: out matriz_tam_marc;
		num_col_activ_out: out std_logic_vector (log_columnas_marc-1 downto 0);
		inicio: out std_logic;
		retardo_random: out std_logic;
		pintar_marc: out std_logic;
		color_marc_out: out color_rgb;
		pintar_laser_marc: out std_logic;
		color_laser_marc: out color_rgb;
		
		puntos_out : out std_logic_vector(1 downto 0);
		llegan_abajo: out std_logic;
		sin_marcianos: out std_logic
	);
end invader_array;

architecture Behavioral of invader_array is
	
	component marciano is
		port(
			clk_vga: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter;
			vcnt: in vertical_counter;
			estado_juego: in estados_juego;
			tipo_marc: in colores_marc;
			pos_x: in horizontal_counter;
			pos_y: in vertical_counter;
			golpeado: in std_logic;
			inicio_matriz: in std_logic;
			
			activo_out: out std_logic;
			vida_out : out std_logic_vector (1 downto 0);
			marc_activo: out std_logic;
			pintar_marc: out std_logic
		);
	end component marciano;
		
	component cod_prior_matriz is
		port (
			matriz: in matriz_tam_marc;
			
			encontrado: out std_logic; 			-- 1 si hay alguno que este a 1
			pos_x: out t_small_int;
			pos_y: out t_small_int
		);

	end component cod_prior_matriz;
	
	component cod_prior_matriz_marc is
		port (
			matriz: in matriz_tam_marc;
			num_disp: in t_small_int;
			
			col_activa_iz: out t_small_int;
			col_activa_der: out t_small_int;
			num_col_activ: out t_small_int;
			primer_activ: out v_small_int_columnas;
			marc_disp: out t_small_int
			
		);
	end component cod_prior_matriz_marc;
	
		--- Ram 1 ------------------------
	
	component invader_easy_ram_abajo is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_easy_ram_abajo;
	
	component invader_easy_ram_arriba is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_easy_ram_arriba;	
	
	--- Ram 2 ------------------------
	
	component invader_medium_ram_abajo is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_medium_ram_abajo;
	
	component invader_medium_ram_arriba is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_medium_ram_arriba;	
	
		--- Ram 3 ------------------------
	
	component invader_hard_ram_abajo is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_hard_ram_abajo;
	
	component invader_hard_ram_arriba is
		 port (clk 		:	in std_logic;
				 addr1 	:	in std_logic_vector(8 downto 0);
				 
				 do1 : out std_logic
		);
	end component invader_hard_ram_arriba;	
	
	
component laser is
	port(	
			clk_fps: in std_logic;		
			clk_vga: in std_logic;			
			reset: in std_logic;			
			hcnt: in horizontal_counter; 		-- Posición del puntero horizontal 
			vcnt: in vertical_counter;			-- Posición del puntero vertical
			estado_juego: in estados_juego;
			activa_laser: in std_logic;		-- Pide activar el laser
			desactiva_laser: in std_logic;	--Pide desactivar el laser
			pos_ini_x: in horizontal_counter;	-- Posición inicial del laser al ser activado
			pos_ini_y: in vertical_counter;
			laser_speed_x: in horizontal_counter; --tienen que ser de este tipo para que sumar un negativo en C1 funcione bien
			laser_speed_y: in vertical_counter;
			
			pinta_laser: out std_logic;		-- Pintar laser
			color: out color_rgb				-- Color del que pintar laser
		);
end component laser;

component cont_laser_marc is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC;
        ret_activa_laser: out STD_LOGIC
		  );
end component cont_laser_marc;

component cont_marc is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end component cont_marc;
	
	constant mejor_visual_iz: integer:= 5;
	constant mejor_visual_der: integer:= 5;
	
	-- Bordes Array
	constant limite_iz: integer := min_screen_x + marc_vel + mejor_visual_iz;
	constant limite_der: integer := max_screen_x - tam_marc_x - marc_vel - mejor_visual_der;	
	
	--iniciar distribucion de marcianos
	signal inicio_matriz, sig_inicio_matriz: std_logic;
	 
	constant distr_lvl1: matriz_id_color:=((M, M, M, M, M, M),
														(L, L, L, L, L, L),
														(L, L, L, L, L, L));
	constant distr_lvl2: matriz_id_color:=((H, H, H, H, H, H),
														(M, M, M, M, M, M),
														(L, L, L, L, L, L));

	-- Constantes Colores Marcianos	
	constant color_easy: color_rgb 		:= "000111000"; -- Verde
	constant color_medium: color_rgb 	:= "111100000"; -- Rojo
	constant color_hard_uno: color_rgb 	:= "111111000"; -- Amarillo
	constant color_hard_dos: color_rgb 	:= "000101111"; -- Azul Claro
	constant color_hard_tres: color_rgb := "000000011"; -- Azul Oscuro
	
	-- Color marc
	signal color_marc: color_rgb;
	
	signal id_color, sig_id_color: matriz_id_color;	
	-- Señales inicio laser
	
	signal pos_ini_x: horizontal_counter;
	signal pos_ini_y: vertical_counter;
	
	
	-- Matriz Posiciones Marcianos
	signal vector_pos_x: t_vector_pos_x;
	signal sig_vector_pos_x: t_vector_pos_x;
	signal vector_pos_y: t_vector_pos_y;
	signal sig_vector_pos_y: t_vector_pos_y;
	-- Señales direccion
	signal dir: dir_marc;
	signal sig_dir: dir_marc;
	signal ant_dir: dir_marc;
	signal sig_ant_dir: dir_marc;
	
	-- Señales pintar	
	signal hay_que_pintar: matriz_tam_marc;
	signal hay_que_pintar_uno: std_logic;
	
	signal pos_a_pintar_x: t_small_int;
	signal pos_a_pintar_y: t_small_int;
	
	-- Señales control matriz
	signal activos: matriz_tam_marc;
	
	signal col_activa_iz: std_logic_vector (small_int-1 downto 0);
	signal col_activa_der: std_logic_vector (small_int-1 downto 0);
	signal num_col_activ: std_logic_vector (small_int-1 downto 0);
	signal primer_activ: v_small_int_columnas;
	
	signal golpeado: matriz_tam_marc;
	
	-- Señal de que algún marciano hay llegado abajo
	signal v_esta_marciano_abajo: std_logic_vector (columnas_marc-1 downto 0);
	
--señales laser marciano
	signal ret_activa_laser: std_logic;
	signal activa_laser: std_logic_vector (num_laser_marc-1 downto 0);
	signal sig_activa_laser: std_logic_vector (num_laser_marc-1 downto 0);
	signal puede_activar: std_logic;
	signal sig_puede_activar: std_logic;
	signal laser_ini_x: horizontal_counter;
	signal laser_ini_y: vertical_counter;
	signal pinta_laser: std_logic;
	signal pinta_laser_aux: std_logic_vector (num_laser_marc-1 downto 0);
	signal colision_laser_aux: std_logic_vector (num_laser_marc-1 downto 0);
	
	type array_color_laser is array (num_laser_marc-1 downto 0) of color_rgb;
	signal color_laser_aux: array_color_laser;
--señales ram
	signal addr_color: std_logic_vector(8 downto 0);
	signal pinta_easy_arriba, pinta_easy_abajo: std_logic;
	signal pinta_medium_arriba, pinta_medium_abajo: std_logic;
	signal pinta_hard_arriba, pinta_hard_abajo: std_logic;
	signal dif_v: vertical_counter;
	signal dif_h: horizontal_counter;
	
	--reloj para movimiento de los marcianos
	signal clk_marc: std_logic;
	
	-- Matriz de vidas
	signal m_vidas : pair_matrix;
	signal puntos, sig_puntos, puntos_aux, sig_puntos_aux : std_logic_vector(1 downto 0);

	-- Posicion Marciano Dispara
	signal marc_disp: t_small_int;

	--debug
	signal activo: matriz_tam_marc;
	
	signal estado_arriba: matriz_tam_marc;
	signal sig_estado_arriba: matriz_tam_marc;
	signal estado_arriba_aux, sig_estado_arriba_aux: std_logic;
begin	
	activo_out <= activo;
	color_marc_out <= color_marc;
	puntos_out <= puntos and puntos_aux;
	cod_matriz_deb: cod_prior_matriz port map 
				(hay_que_pintar, hay_que_pintar_uno, pos_a_pintar_x, pos_a_pintar_y);	
	
	----------- Declaración de Componentes ---------------------
	-- Construccion de la matriz de marcianos
	gen_filas: for i in filas_marc-1 downto 0  generate 
		gen_columnas: for j in columnas_marc-1 downto 0 generate 
			red_marc: marciano port map(
				clk_vga => clk_vga,
				reset => reset,
				hcnt => hcnt,
				vcnt => vcnt,
				estado_juego => estado_juego,
				tipo_marc => sig_id_color (i) (j),
				pos_x => vector_pos_x(j),
				pos_y => vector_pos_y(i),
				golpeado => golpeado (i)(j),
				inicio_matriz => inicio_matriz,
				activo_out => activo (i)(j),
				
				vida_out => m_vidas(i)(j),
				marc_activo => activos (i)(j),
				pintar_marc => hay_que_pintar(i)(j)
				
		);
		end generate gen_columnas;
	end generate gen_filas;
	
	cod_matr_ppal: cod_prior_matriz_marc port map(
			matriz => activos,
			num_disp => random_i,
			
			col_activa_iz => col_activa_iz,
			col_activa_der => col_activa_der,
			num_col_activ => num_col_activ,
			primer_activ => primer_activ,
			marc_disp => marc_disp
		);


	div_marc: cont_marc port map (reset, clk_fps, clk_marc);
	
-- Rams Dibujos Marcianos
	ram_color_easy_arriba: invader_easy_ram_abajo port map (clk_main, addr_color, pinta_easy_arriba);
	ram_color_medium_arriba: invader_medium_ram_arriba port map (clk_main, addr_color, pinta_medium_arriba);
	ram_color_hard_arriba: invader_hard_ram_abajo port map (clk_main, addr_color, pinta_hard_arriba);
	ram_color_easy_abajo: invader_easy_ram_arriba port map (clk_main, addr_color, pinta_easy_abajo);
	ram_color_medium_abajo: invader_medium_ram_abajo port map (clk_main, addr_color, pinta_medium_abajo);
	ram_color_hard_abajo: invader_hard_ram_arriba port map (clk_main, addr_color, pinta_hard_abajo);


	
	colision_laser_aux <= pinta_laser_aux when colision_laser = '1' else -- equiv a pinta_laser_aux and "11111"
								(others => '0');
		
		
	
	------------------------------------------	
	inicio <= puede_activar and ret_activa_laser;
	retardo_random <= ret_activa_laser;
	num_col_activ_out <= num_col_activ(log_columnas_marc-1 downto 0);--cambiar quitando el tamaño cuando num_col_activ tenga el tamaño de log_col_marc
	-------------------------------------------
	
	pos_ini_x <= sig_vector_pos_x (conv_integer(marc_disp)) + semi_tam_marc_x;
	pos_ini_y <= sig_vector_pos_y (conv_integer(primer_activ(conv_integer(marc_disp))));
	



	laser_marc: for i in  num_laser_marc-1 downto 0 generate
			l: laser port map(	
				clk_fps => clk_fps, 		
				clk_vga => clk_vga, 		
				reset => reset,		
				hcnt => hcnt,
				vcnt => vcnt,
				estado_juego => estado_juego,
				activa_laser => activa_laser(i),
				desactiva_laser => colision_laser_aux (i),
				pos_ini_x => pos_ini_x, -- Se pone el siguiente porque sino va a salir un frame por detras al activarse
				pos_ini_y =>  pos_ini_y,
				laser_speed_x => conv_std_logic_vector(i-2, tam_h_counter),
				laser_speed_y => conv_std_logic_vector(-4, tam_v_counter),
				
				pinta_laser => pinta_laser_aux(i),
				color => color_laser_aux(i)
			);
	end generate laser_marc;
		
	retardo: cont_laser_marc port map (reset, clk_fps, ret_activa_laser);		
	
	pr_hay_que_pintar_marc: process (hay_que_pintar_uno, estado_juego)
	begin
		if hay_que_pintar_uno = '1' and (estado_juego = LEVEL1 or estado_juego = LEVEL2 
			or estado_juego = YOUR_LEVEL or estado_juego = SET_LEVEL) and color_marc /= color_fondo then
			pintar_marc <= '1';
		else
			pintar_marc <= '0';
		end if;
	end process pr_hay_que_pintar_marc;
	
	pr_pintar_laser: process (pinta_laser, estado_juego)
	begin
		if pinta_laser = '1' and (estado_juego = LEVEL1 or estado_juego = LEVEL2 or estado_juego = YOUR_LEVEL) then
			pintar_laser_marc <= '1';
		else
			pintar_laser_marc <= '0';
		end if;
	end process pr_pintar_laser;

	-------------------------------------------------------------------------------------------
	--se asigna a addr_color la dirección del bit de ram con respecto al marciano en donde está el puntero de pantalla
	dif_h <= hcnt - vector_pos_x(conv_integer(pos_a_pintar_x));
	dif_v <= vcnt - vector_pos_y(conv_integer(pos_a_pintar_y));
	addr_color <= dif_v(4 downto 0) & dif_h(3 downto 0);
	
	pinta_laser <= '0' when pinta_laser_aux = "00000" else
						'1';
	
							
	color_laser_marc <= 	color_laser_aux(0) when pinta_laser_aux(0) = '1' else
								color_laser_aux(1) when pinta_laser_aux(1) = '1' else
								color_laser_aux(2) when pinta_laser_aux(2) = '1' else
								color_laser_aux(3) when pinta_laser_aux(3) = '1' else
								color_laser_aux(4) when pinta_laser_aux(4) = '1' else
								(others => '0');

	
	pr_main: process (reset, clk_vga, estado_juego, sig_inicio_matriz, sig_id_color)
	begin
		if reset = '1'  or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
					and  estado_juego /= YOUR_LEVEL and estado_juego /= SET_LEVEL)  then
			--ahora mismo no parpadea el marciano seleccionado en el estado SET_LEVEL, habrá que cambiarlo despues
			inicio_matriz <= '1';
		elsif (clk_vga'event and clk_vga='1') then
			inicio_matriz <= sig_inicio_matriz;
			id_color <= sig_id_color;
		end if;
	end process pr_main;
	
	pr_vga2: process (reset, clk_vga)
	begin
		if reset = '1'  then
			puntos <= (others => '0');
		elsif (clk_vga'event and clk_vga='1') then
			puntos <= sig_puntos;
			puntos_aux <= sig_puntos_aux;
		end if;
	end process pr_vga2;
	

	pr_color_marc: process (estado_arriba, id_color, pinta_hard_arriba, pinta_hard_abajo, pinta_medium_arriba, pinta_medium_abajo, pinta_easy_arriba, pinta_easy_abajo)
	begin
		color_marc <= color_fondo;
		if id_color(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = L then
			if (estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = '1' and pinta_easy_arriba = '1') or 
				(estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = '0' and pinta_easy_abajo = '1') then
				
				color_marc <= color_easy;
			end if;
		elsif id_color(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = M then
			if (estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = '1' and pinta_medium_arriba = '1') or 
				(estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x))= '0' and pinta_medium_abajo = '1') then
				
				color_marc <= color_medium;
			end if;
		elsif id_color(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = H then
			if (estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = '1' and pinta_hard_arriba = '1') or 
				(estado_arriba (conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x))= '0' and pinta_hard_abajo = '1') then
				
				if m_vidas(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = "11" then
					color_marc <= color_hard_tres;
				elsif m_vidas(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = "10" then
					color_marc <= color_hard_dos;
				elsif m_vidas(conv_integer(pos_a_pintar_y))(conv_integer(pos_a_pintar_x)) = "01" then
					color_marc <= color_hard_uno;
				end if;
			end if;
		end if;
	end process pr_color_marc;
	
	
	pr_inicializacion: process (id_color, estado_juego, distr_your_lvl)
	begin
		sig_id_color <= id_color;

		if inicio_matriz = '1' then
				sig_inicio_matriz <= '0';
			if estado_juego = LEVEL1 then
				sig_id_color <= distr_lvl1;
			elsif estado_juego = LEVEL2 then
				sig_id_color <= distr_lvl2;
			elsif estado_juego = YOUR_LEVEL then
					sig_id_color <= distr_your_lvl;
			elsif estado_juego = SET_LEVEL then
				sig_id_color <= distr_your_lvl;
				sig_inicio_matriz <= '1';
			end if;
		end if;
	end process pr_inicializacion;
	
	pr_fps: process (clk_fps,reset, estado_juego)
	begin
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2 and estado_juego /= YOUR_LEVEL)  then
			puede_activar <= '0';
			activa_laser <= (others => '0');
		elsif (clk_fps'event and clk_fps='1') then
			puede_activar <= sig_puede_activar;
			activa_laser <= sig_activa_laser;
			-- Si la dir estuviera en clk_main no bajan los marcianos porque no se actualiza la posicion
			-- de los marcianos a tiempo
		end if;
	end process pr_fps;

	pr_clk_marc: process (clk_marc,reset, estado_juego)
	begin
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2 and estado_juego /= YOUR_LEVEL)  then
			--en estado_juego = SET_LEVEL quiero que la posicion de los marcianos sea siempre la inicial
			--me falta hacer que parpadee el marciano seleccionado
			vector_pos_x <= vector_ini_x;
			vector_pos_y <= vector_ini_y;
			
			dir <= DERECHA;
			ant_dir <= DERECHA;
		elsif (clk_marc'event and clk_marc='1') then
			vector_pos_x <= sig_vector_pos_x;
			vector_pos_y <= sig_vector_pos_y;
			
			dir <= sig_dir;
			ant_dir <= sig_ant_dir;
		end if;
	end process pr_clk_marc;
	
	pr_clk_marc2: process (clk_marc,reset, estado_juego)
	begin
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2 and estado_juego /= YOUR_LEVEL and estado_juego /= SET_LEVEL)  then
			estado_arriba <= (others => (others => '0'));
			estado_arriba_aux <= '0';
		elsif (clk_marc'event and clk_marc='1') then
			estado_arriba <= sig_estado_arriba;
			estado_arriba_aux <= sig_estado_arriba_aux;
		end if;
	end process pr_clk_marc2;
	
	pr_estado_arriba: process (estado_arriba)
	begin
	for i in filas_marc -1 downto 0 loop
		for j in columnas_marc-1 downto 0 loop
			if estado_juego = SET_LEVEL then
				if i = conv_integer (set_y) and j = conv_integer (set_x) then
					sig_estado_arriba(i)(j) <= not estado_arriba(i)(j);
				else 
					sig_estado_arriba(i)(j) <= '0';
				end if;
			else
				sig_estado_arriba(i)(j) <= estado_arriba_aux;
			end if;
		end loop;
	end loop;
	sig_estado_arriba_aux <= not estado_arriba_aux;
	
	end process pr_estado_arriba;
	
	-- Establece la siguiente direccion que debe tomar el marciano
	next_dir: process (dir, vector_pos_x, ant_dir)
	begin
		if dir = DERECHA then
			if vector_pos_x(conv_integer (col_activa_der)) > limite_der then
				sig_dir <= ABAJO;
			else
				sig_dir <= DERECHA;
			end if;
			sig_ant_dir <= DERECHA;
		elsif dir = IZQUIERDA then
			if vector_pos_x(conv_integer (col_activa_iz)) < limite_iz then
				sig_dir <= ABAJO;
			else
				sig_dir <= IZQUIERDA;
			end if;
			sig_ant_dir <= IZQUIERDA;
		elsif dir = ABAJO then
			if ant_dir = DERECHA then
				sig_dir <= IZQUIERDA;
			else
				sig_dir <= DERECHA;
			end if;
			sig_ant_dir <= ABAJO; -- Latches
		else -- dir = desactivado que aqui no se va a dar nunca
			sig_dir <= DESACTIVADO;
			sig_ant_dir <= DESACTIVADO;
		end if;	
	end process next_dir;
	
	next_matriz_pos: process (dir, vector_pos_x, vector_pos_y)
	begin
		if dir = DERECHA then
			der: for i in columnas_marc-1 downto 0 loop
				sig_vector_pos_x(i) <= vector_pos_x(i) + marc_vel;
			end loop;
			sig_vector_pos_y <= vector_pos_y;
		elsif dir = IZQUIERDA then
			iz: for i in columnas_marc-1 downto 0 loop
				sig_vector_pos_x(i) <= vector_pos_x(i) - marc_vel;
			end loop;
			sig_vector_pos_y <= vector_pos_y;
		elsif dir = ABAJO then
		
			ab: for i in filas_marc-1 downto 0 loop
				sig_vector_pos_y(i) <= vector_pos_y(i) + marc_vel_bajada;
			end loop;
			sig_vector_pos_x <= vector_pos_x;
		else -- Desactivado
			sig_vector_pos_x <= vector_pos_x;
			sig_vector_pos_y <= vector_pos_y;
		end if;	
	end process next_matriz_pos;
	
	-- Actualiza sig_activa_laser y sig_puede_activar
	pr_activa_laser_fuer: process (puede_activar, ret_activa_laser)
	begin
		if id_color (conv_integer(primer_activ(conv_integer(marc_disp)))) (conv_integer(marc_disp)) = H then -- Cambiar por el numero del random 
			sig_activa_laser <= (others => (puede_activar and ret_activa_laser));
		else
			sig_activa_laser <= "00" & (puede_activar and ret_activa_laser) & "00";
		end if;
	end process pr_activa_laser_fuer;
	
	--sig_activa_laser <= puede_activar and ret_activa_laser;
	sig_puede_activar <= not ret_activa_laser; -- Equiv a not ((puede_activar and ret_activa_laser) or ret_activa_laser)

	sig_puntos_aux <= not puntos;
	
	colision: process (colision_marc, activos)
	begin	
		golpeado <= (others => (others => '0'));
		sig_puntos <= (others => '0');
		if colision_marc = '1' then
			golpeado (conv_integer(pos_a_pintar_y)) (conv_integer(pos_a_pintar_x)) <= '1';
			if m_vidas (conv_integer(pos_a_pintar_y)) (conv_integer(pos_a_pintar_x)) = "01" then
				if id_color (conv_integer(pos_a_pintar_y)) (conv_integer(pos_a_pintar_x)) = L then
					sig_puntos <= "01";
				elsif id_color (conv_integer(pos_a_pintar_y)) (conv_integer(pos_a_pintar_x)) = M then
					sig_puntos <= "10";
				elsif id_color (conv_integer(pos_a_pintar_y)) (conv_integer(pos_a_pintar_x)) = H then
					sig_puntos <= "11";
				end if;
			end if;
		end if;
	end process colision;
	
	-- Procesos para ver si se termina el juego

	pr_no_marc: process (num_col_activ)
	begin
		if unsigned(num_col_activ) = 0 then
			sin_marcianos <= '1';
		else
			sin_marcianos <= '0';
		end if;
	end process pr_no_marc;
	
	pr_llegan_abajo: process (estado_juego, vector_pos_y, activos, v_esta_marciano_abajo)
	begin
		if estado_juego = LEVEL1 or estado_juego = LEVEL2 or estado_juego = YOUR_LEVEL then
			l: for i in columnas_marc-1 downto 0 loop -- constant inicio_v: vertical_counter := conv_std_logic_vector(360, tam_v_counter);
				if vector_pos_y(conv_integer (primer_activ(i))) > 360 and activos (conv_integer (primer_activ(i))) (i) = '1' then
					v_esta_marciano_abajo (i) <= '1';
				else
					v_esta_marciano_abajo (i) <= '0';
				end if;
			end loop;
		else
			v_esta_marciano_abajo <= (others => '0');
		end if;
		
		if unsigned(v_esta_marciano_abajo) = 0 then
			llegan_abajo <= '0';
		else
			llegan_abajo <= '1';
		end if;
	end process pr_llegan_abajo;

end Behavioral;

