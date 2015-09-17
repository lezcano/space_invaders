library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;
--reloj pantalla X"196E6A" "11001011011100110101"

entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clk: in std_logic;
		
		PS2CLK: in std_logic;
		PS2DATA: in std_logic;
		
		
		debug: out std_logic_vector (8 downto 0);
		debug2: out std_logic_vector (6 downto 0);
		debug3: out std_logic_vector (6 downto 0);
		hsyncb: inout std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;		-- vertical (frame) sync
		rgb: out std_logic_vector(8 downto 0) -- red,green,blue colors
		);
end vgacore;

architecture vgacore_arch of vgacore is

component nave is
	port(	
			clk_fps: in std_logic;
			clk_vga: in std_logic;
			clk_main: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posici髇 del puntero horizontal 
			vcnt: in vertical_counter;				-- Posici髇 del puntero vertical	
			accion_nave: in accion;
			estado_juego: in estados_juego;
			colision_nave: in std_logic;
			
			pintar_nave: out std_logic;			-- Pintar nave
			color: out color_rgb;					-- Color de la nave
			pos_x_out: out horizontal_counter;	-- Posicion horizontal para posici髇 inicial del laser al disparar
			pos_y_out: out vertical_counter;	-- Posicion vertical para posici髇 inicial del laser al disparar
			vida_out: out std_logic_vector;
			nave_muerta: out std_logic
		);
end component;

component laser_array is
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
end component laser_array;

component invader_array is
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
end component invader_array;

component teclado_reg is
	port(
			entrada: in std_logic;
			clk: in std_logic;
			reset: in std_logic;
			tecla: out accion
		);
end component;

component colision_lvl_1 is
	port
	(	
		is_nave: in std_logic;
		is_laser: in std_logic;
		is_marciano: in std_logic;
		is_laser_marciano: in std_logic;
		is_barrera_1: in std_logic;
		is_barrera_2: in std_logic;
		is_barrera_3: in std_logic;
		
		colision_nave: out std_logic;
		colision_laser: out std_logic;
		colision_marciano: out std_logic;
		colision_laser_marciano: out std_logic;
		colision_barrera_1: out std_logic;
		colision_barrera_2: out std_logic;
		colision_barrera_3: out std_logic
	);
end component colision_lvl_1;

component cont_vga is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end component;

component cont_fps is
    port (
        reset: in STD_LOGIC;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC; -- reloj que se utiliza en los process del programa principal
		  seed: out std_logic_vector(11 downto 0)
    );
end component;

component pant_inicial is
	port(
		clk_main: in std_logic;
		clk_fps: in std_logic;
		clk_vga: in std_logic;
		reset: in std_logic;
		tecla: in accion;
		hcnt: in horizontal_counter; 			-- Posici髇 del puntero horizontal 
		vcnt: in vertical_counter;				-- Posici髇 del puntero vertical
		sin_vidas: in std_logic;
		marc_llegan_abajo: in std_logic;
		sin_marc: in std_logic;
		
		estado_out: out estados_juego;
		distr_your_lvl: out matriz_id_color;
		set_x_out: out std_logic_vector (log_columnas_marc-1 downto 0);
		set_y_out: out std_logic_vector (log_filas_marc-1 downto 0);
		pintar_pant_ini: out std_logic;
		color: out color_rgb
	);
end component;

component barrera is
	port(
			clk: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posici髇 del puntero horizontal 
			vcnt: in vertical_counter;				-- Posici髇 del puntero vertical	
			colision_barrera: in std_logic;
			inicio_v : in vertical_counter;
			inicio_h : in horizontal_counter;
			estado_juego: in estados_juego;
			tam_barrera_x : in integer;
			tam_barrera_y : in integer;
			
			pintar_barrera: out std_logic;			-- Pintar barrera
			color: out color_rgb					-- Color de la barrera
	);
end component;

component rand_mod is
	port (
		clk: in std_logic;
		reset: in std_logic;
		num_col_act: std_logic_vector(log_columnas_marc-1 downto 0);
		seed: in std_logic_vector(127 downto 0);
		inicio: in std_logic;
		retardo: in std_logic;
		
		modulo: out std_logic_vector(log_columnas_marc-1 downto 0)
	);
end component rand_mod;

component marcador is
	port(
			clk: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posici髇 del puntero horizontal 
			vcnt: in vertical_counter;				-- Posici髇 del puntero vertical	
			ptos_2 : in t_small_int;
			ptos_3 : in t_small_int;
			ptos_4 : in t_small_int;
			num_a_mostrar : in t_small_int;
			estado_juego: in estados_juego;
			
			pintar_0: out std_logic;
			pintar_1: out std_logic;
			pintar_2: out std_logic;
			pintar_3: out std_logic;
			pintar_4: out std_logic;
			color: out color_rgb		
	
	);
end component;

component sumador_puntos is
	port(
			clk: in std_logic;
			reset: in std_logic;
			
			numero: in t_small_int;
			estado_juego: in estados_juego;
			
			num_2_out : out t_small_int;
			num_3_out : out t_small_int;
			num_4_out : out t_small_int;
			
			num_a_mostrar_out : out t_small_int
	);
end component;

constant grosor_cuadro: natural := 5;
constant color_cuadro: color_rgb := "000110101";
constant color_vidas_nave: color_rgb := "111001010";



signal hcnt: std_logic_vector(8 downto 0);	-- horizontal pixel counter
signal vcnt: std_logic_vector(9 downto 0);	-- vertical line counter
signal pintar_nave: std_logic;						-- video blanking signal

signal estado_juego: estados_juego; 

-- Relojes
signal clk_vga: std_logic;		
signal clk_fps: std_logic;

-- Colores a pintar
signal color_nave: color_rgb;
signal color_laser: color_rgb;

signal pos_x_nave: horizontal_counter;
signal pos_y_nave: vertical_counter;
signal pos_ini_laser_x: horizontal_counter;
signal pos_ini_laser_y: vertical_counter;
signal random_i: std_logic_vector (log_columnas_marc-1 downto 0);

signal activar_laser: std_logic; 
signal pintar_laser: std_logic;
signal accion_pedida: accion;

-- Marcianos
signal pintar_marc: std_logic;
signal pintar_laser_marc: std_logic;
signal color_marc: color_rgb;
signal color_laser_marc: color_rgb;

--Colisiones
signal colision_nave: std_logic;
signal colision_laser: std_logic;
signal colision_marc: std_logic;
signal colision_laser_marc: std_logic;
signal colision_barrera_1: std_logic;
signal colision_barrera_2: std_logic;
signal colision_barrera_3: std_logic;

--cambio estados juegos
signal nave_muerta: std_logic;
signal llegan_abajo: std_logic;
signal sin_marcianos: std_logic;

--se馻les para aleatorios
signal num_col_activ: std_logic_vector (log_columnas_marc-1 downto 0);
signal inicio: std_logic;
signal seed: std_logic_vector (11 downto 0);
signal retardo_random: std_logic;
constant zeros_for_seed: std_logic_vector (115 downto 0) := conv_std_logic_vector (0, 116);
constant zeros_for_rand: std_logic_vector (2 downto 0) := conv_std_logic_vector (0, 3);
signal big_seed: std_logic_vector (127 downto 0);
signal reset_aleatorio: std_logic;

--se馻les de pantalla inicial
signal pintar_pant_ini: std_logic;
signal color_pant_ini: color_rgb;
signal distr_your_lvl: matriz_id_color;
signal set_x: std_logic_vector (log_columnas_marc-1 downto 0);
signal set_y: std_logic_vector (log_filas_marc-1 downto 0);

-- Barrera 1
signal pintar_barrera_1: std_logic;
signal color_barrera_1: color_rgb;
constant inicio_barr_v1: vertical_counter := conv_std_logic_vector(300, tam_v_counter);
constant inicio_barr_h1: horizontal_counter := conv_std_logic_vector(41, tam_h_counter);
-- Barrera 2
signal pintar_barrera_2: std_logic;
signal color_barrera_2: color_rgb;
constant inicio_barr_v2: vertical_counter := conv_std_logic_vector(300, tam_v_counter);
constant inicio_barr_h2: horizontal_counter := conv_std_logic_vector(114, tam_h_counter);
-- Barrera 3
signal pintar_barrera_3: std_logic;
signal color_barrera_3: color_rgb;
constant inicio_barr_v3: vertical_counter := conv_std_logic_vector(300, tam_v_counter);
constant inicio_barr_h3: horizontal_counter := conv_std_logic_vector(187, tam_h_counter);

--Vidas nave
signal vidas_nave: std_logic_vector (1 downto 0);

signal rand_extent: t_small_int;

-- Marcador
signal num_2 : std_logic_vector(6 downto 0) 	:= "0111111";
signal num_3 : std_logic_vector(6 downto 0)	:= "0111111";
signal num_4 : std_logic_vector(6 downto 0)	:= "0111111";
signal pintar_0 : std_logic;
signal pintar_1 : std_logic;
signal pintar_2 : std_logic;
signal pintar_3 : std_logic;
signal pintar_4 : std_logic;
signal color_marcador : color_rgb;

-- Numero (debug)
signal activos : std_logic_vector(6 downto 0) := "1010111";
signal pintar_numero : std_logic;
signal color_num : color_rgb;

-- Sumador
signal load : std_logic;
signal num_2_sum : t_small_int := conv_std_logic_vector(0,small_int);
signal num_3_sum : t_small_int := conv_std_logic_vector(0,small_int);
signal num_4_sum : t_small_int := conv_std_logic_vector(0,small_int);
signal ptos_sumador : t_small_int := conv_std_logic_vector(0,small_int);

signal num_2_sum_out : t_small_int;
signal num_3_sum_out : t_small_int;
signal num_4_sum_out : t_small_int;

signal num_a_mostrar : t_small_int;
signal calculado : std_logic;
signal puntos : std_logic_vector(1 downto 0);

--debug
signal activo: matriz_tam_marc;

begin

rand_extent <= zeros_for_rand & random_i;

teclado: teclado_reg port map (PS2DATA, PS2CLK,  reset, accion_pedida);	
divisor_vga: cont_vga port map (reset, clk, clk_vga);
divisor_fps: cont_fps port map (reset, clk, clk_fps, seed);


with puntos select
	ptos_sumador <= 	conv_std_logic_vector(1,small_int) when "01",
							conv_std_logic_vector(2,small_int) when "10",
							conv_std_logic_vector(5,small_int) when "11",
							conv_std_logic_vector(0,small_int) when others;
							

with estado_juego select
	debug2 <= 	"0000001" when INIT_SCR,
					"0000010" when LEVEL1,
					"0000100" WHEN LEVEL2, 
					"0001000" WHEN WIN,
					"0010000" WHEN LOSE,
					"0100000" WHEN SET_LEVEL,
					"1111111" WHEN YOUR_LEVEL,
					"1000000" WHEN OTHERS;
		
		debug <= (others => '0');
		debug3 <= (others => '0');
pos_ini_laser_x <= pos_x_nave + semi_tam_nave_x;
pos_ini_laser_y <= pos_y_nave - tam_laser_y;

big_seed <= zeros_for_seed & seed;

reset_aleatorio <= 	'1' when (estado_juego /= LEVEL1) and (estado_juego/= LEVEL2) and (estado_juego/= YOUR_LEVEL) else
							'0';

nave_u: nave port map (
				clk_fps => clk_fps,
				clk_vga => clk_vga,
				clk_main => clk,
				reset => reset,
				hcnt => hcnt,   			
				vcnt => vcnt,			
				accion_nave => accion_pedida,
				estado_juego => estado_juego,
				colision_nave => colision_nave,
				
				pintar_nave => pintar_nave,
				color => color_nave,				
				pos_x_out => pos_x_nave,
				pos_y_out => pos_y_nave,
				vida_out => vidas_nave,
				nave_muerta => nave_muerta
			);

laser_u: laser_array port map ( -- Se le pasa el reloj de la vga por como esta hecho el desactiva disp
			clk_fps => clk_fps,
			clk_main => clk,
			clk_vga => clk_vga,
			reset => reset,			
			hcnt => hcnt,   			 
			vcnt => vcnt,				
			estado_juego => estado_juego,
			activa_laser => activar_laser,	
			pos_nave_x => pos_ini_laser_x,	
			pos_nave_y => pos_ini_laser_y,
			colision_laser => colision_laser,
			
			debug => open,
			pinta_laser => pintar_laser,			
			color_laser => color_laser

		);

marcianos_u: invader_array port map(
					clk_fps => clk_fps,
					clk_vga => clk_vga,
					clk_main => clk,			
					reset => reset,			
					hcnt => hcnt,   			 
					vcnt => vcnt,				
					estado_juego => estado_juego,
					colision_marc => colision_marc,
					random_i => rand_extent,
					colision_laser => colision_laser_marc,
					distr_your_lvl => distr_your_lvl,
					set_x => set_x,
					set_y => set_y,
					
					debug => open,
					debug2 => open,
					debug3 => open,
					activo_out => activo,
					num_col_activ_out => num_col_activ,
					inicio => inicio,
					retardo_random => retardo_random,
					pintar_marc => pintar_marc,
					color_marc_out => color_marc,
					pintar_laser_marc => pintar_laser_marc,
					color_laser_marc => color_laser_marc,
					
					puntos_out => puntos,
					llegan_abajo => llegan_abajo,
					sin_marcianos => sin_marcianos
				);
scr_ini: pant_inicial port map (
		clk_main => clk,
		clk_fps => clk_fps,
		clk_vga => clk_vga,
		reset  => reset,
		tecla  => accion_pedida,
		hcnt  => hcnt,
		vcnt => vcnt,
		sin_vidas => nave_muerta,
		marc_llegan_abajo => llegan_abajo,
		sin_marc => sin_marcianos,
		
		estado_out => estado_juego,
		distr_your_lvl => distr_your_lvl,
		set_x_out => set_x,
		set_y_out => set_y,
		pintar_pant_ini => pintar_pant_ini,
		color  => color_pant_ini
	);

--De momento el '0' es la entrada de is_laser_marciano y la colision se deja desconectada
colision1: colision_lvl_1 port map (
		is_nave => pintar_nave,
		is_laser => pintar_laser,
		is_marciano => pintar_marc, 		
		is_laser_marciano => pintar_laser_marc,
		is_barrera_1 => pintar_barrera_1,
		is_barrera_2 => pintar_barrera_2,
		is_barrera_3 => pintar_barrera_3,
		
		colision_nave => colision_nave, 
		colision_laser => colision_laser,
		colision_marciano => colision_marc, 
		colision_laser_marciano => colision_laser_marc,
		colision_barrera_1 => colision_barrera_1,
		colision_barrera_2 => colision_barrera_2,
		colision_barrera_3 => colision_barrera_3
	);
	
	-- Barrera
barr_1: barrera port map(
		clk_vga, 
		reset, 
		hcnt, 
		vcnt, 
		colision_barrera_1, 
		inicio_barr_v1, 
		inicio_barr_h1,
		estado_juego,
		tam_barrera_x,
		tam_barrera_y,
		
		pintar_barrera_1, 
		color_barrera_1
	);

barr_2: barrera port map(
		clk_vga, 
		reset, 
		hcnt, 
		vcnt, 
		colision_barrera_2, 
		inicio_barr_v2, 
		inicio_barr_h2,
		 estado_juego,
		tam_barrera_x,
		tam_barrera_y,
		
		pintar_barrera_2, 
		color_barrera_2
	);
	
barr_3: barrera port map(
		clk_vga, 
		reset, 
		hcnt, 
		vcnt, 
		colision_barrera_3, 
		inicio_barr_v3, 
		inicio_barr_h3, 
		estado_juego,
		tam_barrera_x,
		tam_barrera_y,
		
		pintar_barrera_3, 
		color_barrera_3
	);
r_num: rand_mod port map(
		clk => clk,
		reset => reset_aleatorio,
		num_col_act => num_col_activ,
		seed => big_seed,
		inicio => inicio,
		retardo => retardo_random,
		
		modulo => random_i
	);

	
marcad: marcador port map(
	clk_vga,
	reset,
	hcnt,
	vcnt,
	num_2_sum_out,
	num_3_sum_out,
	num_4_sum_out,
	num_a_mostrar,
	estado_juego,
	
	pintar_0,
	pintar_1,
	pintar_2,
	pintar_3,
	pintar_4,
	color_marcador
	
);
	
sumador : sumador_puntos port map(
	clk_vga,
	reset,
	ptos_sumador,
	estado_juego,
	
	num_2_sum_out,
	num_3_sum_out,
	num_4_sum_out,
	num_a_mostrar
);
	
----------------------------------------------------------------------------
A: process(clk_vga,reset)
begin
	
	-- reset asynchronously clears pixel counter
	if reset='1' then
		hcnt <= "000000000";
	-- horiz. pixel counter increments on rising edge of dot clk_vga
	elsif (clk_vga'event and clk_vga='1') then
		-- horiz. pixel counter rolls-over after 381 pixels
		if hcnt<380 then
			hcnt <= hcnt + 1;
		else
			hcnt <= "000000000";
		end if;
	end if;
end process;

B: process(hsyncb,reset)
begin
	-- reset asynchronously clears line counter
	if reset='1' then
		vcnt <= "0000000000";
	-- vert. line counter increments after every horiz. line
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. line counter rolls-over after 528 lines
		if vcnt<527 then
			vcnt <= vcnt + 1;
		else
			vcnt <= "0000000000";
		end if;
	end if;
end process;

C: process(clk_vga,reset)
begin
	-- reset asynchronously sets horizontal sync to inactive
	if reset='1' then
		hsyncb <= '1';
	-- horizontal sync is recomputed on the rising edge of every dot clk_vga
	elsif (clk_vga'event and clk_vga='1') then
		-- horiz. sync is low in this interval to signal start of a new line
		if (hcnt>=291 and hcnt<337) then
			hsyncb <= '0';
		else
			hsyncb <= '1';
		end if;
	end if;
end process;

D: process(hsyncb,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if reset='1' then
		vsyncb <= '1';
	-- vertical sync is recomputed at the end of every line of pixels
	elsif (hsyncb'event and hsyncb='1') then
		-- vert. sync is low in this interval to signal start of a new frame
		if (vcnt>=490 and vcnt<492) then
			vsyncb <= '0';
		else
			vsyncb <= '1';
		end if;
	end if;
end process;
----------------------------------------------------------------------------


with accion_pedida select
activar_laser <= '1' when DISPARAR,
                  '0' when others;


pintar: process (hcnt, vcnt, pintar_nave, color_nave, pintar_laser, color_laser, pintar_marc, color_marc, pintar_laser_marc, color_laser_marc) -- Quita warnings, en verdad valdria con hcnt y vcnt
begin
	if estado_juego = LEVEL1 or estado_juego = LEVEL2 or 
		estado_juego = YOUR_LEVEL or estado_juego = SET_LEVEL then
		if pintar_marc = '1' then 
			rgb <= color_marc;
		elsif estado_juego /= SET_LEVEL then
			if 	((hcnt > max_screen_x)	--barra vertical derecha
					and hcnt < (max_screen_x + grosor_cuadro)
					and vcnt > (min_screen_y - grosor_cuadro)
					and vcnt < (max_screen_y + grosor_cuadro) ) 
					then
				rgb <= color_cuadro;
			elsif	((hcnt < min_screen_x) --barra vertical izquierda
					and hcnt > (min_screen_x - grosor_cuadro)
					and vcnt > (min_screen_y - grosor_cuadro)
					and vcnt < (max_screen_y + grosor_cuadro) )
					then		
				rgb <= color_cuadro;
				
			elsif pintar_nave = '1' then
				rgb <= color_nave;
			elsif pintar_laser = '1' then
				rgb <= color_laser;
			elsif pintar_laser_marc = '1' then 
				rgb <= color_laser_marc;
			elsif pintar_barrera_1 = '1' then
				rgb <= color_barrera_1;
			elsif pintar_barrera_2 = '1' then
				rgb <= color_barrera_2;
			elsif pintar_barrera_3 = '1' then
				rgb <= color_barrera_3;
			elsif vidas_nave > "00"
				and	hcnt > pos_vida1_x
				and hcnt < (pos_vida1_x + tam_vida_nave_x)
				and vcnt > pos_vida_y
				and vcnt < (pos_vida_y + tam_vida_nave_y) then 
					rgb <= color_vidas_nave;
			elsif vidas_nave > "01"
				and	hcnt > pos_vida2_x
				and hcnt < (pos_vida2_x + tam_vida_nave_x)
				and vcnt > pos_vida_y
				and vcnt < (pos_vida_y + tam_vida_nave_y) then 
					rgb <= color_vidas_nave;
			elsif vidas_nave > "10"
				and	hcnt > pos_vida3_x
				and hcnt < (pos_vida3_x + tam_vida_nave_x)
				and vcnt > pos_vida_y
				and vcnt < (pos_vida_y + tam_vida_nave_y) then 
					rgb <= color_vidas_nave;		
			elsif pintar_0 = '1' then
				rgb <= color_marcador;	
			elsif pintar_1 = '1' then
				rgb <= color_marcador;	
			elsif pintar_2 = '1' then
				rgb <= color_marcador;	
			elsif pintar_3 = '1' then
				rgb <= color_marcador;	
			elsif pintar_4 = '1' then
				rgb <= color_marcador;
			else 
				rgb <= color_fondo;
			end if;
		else
			rgb <= color_fondo;
		end if;
	elsif estado_juego = INIT_SCR or estado_juego = WIN or estado_juego = LOSE then
		if pintar_pant_ini = '1' then
			rgb <= color_pant_ini;
		elsif estado_juego /= INIT_SCR then
			if pintar_0 = '1' then
				rgb <= color_marcador;	
			elsif pintar_1 = '1' then
				rgb <= color_marcador;	
			elsif pintar_2 = '1' then
				rgb <= color_marcador;	
			elsif pintar_3 = '1' then
				rgb <= color_marcador;	
			elsif pintar_4 = '1' then
				rgb <= color_marcador;
			else
				rgb <= color_fondo;
			end if;
		else
			rgb <= color_fondo;
		end if;
	else
		rgb <= color_fondo;
	end if;
end process;

end vgacore_arch;