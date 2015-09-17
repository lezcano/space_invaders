library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;


entity pant_inicial is
	port(
		clk_main: in std_logic;
		clk_fps: in std_logic;
		clk_vga: in std_logic;
		reset: in std_logic;
		tecla: in accion;
		hcnt: in horizontal_counter; 			-- Posición del puntero horizontal 
		vcnt: in vertical_counter;				-- Posición del puntero vertical
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
end pant_inicial;

architecture Behavioral of pant_inicial is

component cont_retardo_tecla is 
    port (
        reset: in STD_LOGIC;
		  reinicia: in std_logic;
        clk_entrada: in STD_LOGIC; -- reloj de entrada de la entity superior
        clk_salida: out STD_LOGIC -- reloj que se utiliza en los process del programa principal
    );
end component cont_retardo_tecla;

component nivel_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(9 downto 0);--32x32
			 
          do1 : out color_rgb
	);
end component;

component uno_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(8 downto 0); --32x16
			 
          do1 : out color_rgb
	);
end component;

component dos_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(8 downto 0); --32x16
			 
          do1 : out color_rgb
	);
end component;

component flecha_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(6 downto 0);--flecha de 16x8
			 
          do1 : out color_rgb
	);
end component;

component crea_tu_ram is
    port (clk 		:	in std_logic;--32x32
          addr1 	:	in std_logic_vector(10 downto 0);
			 
          do1 		: 	out color_rgb
	);
end component;

component win_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(12 downto 0);--flecha de 64x128
			 
          do1 : out color_rgb
	);
end component;

component lose_ram is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(12 downto 0);--flecha de 64x128
			 
          do1 : out color_rgb
	);
end component;

--component space_invaders_ram is
--    port (clk 		:	in std_logic;
--          addr1 	:	in std_logic_vector(12 downto 0);
--			 
--          do1 		: 	out std_logic_vector(8 downto 0)
--	);
--end component;

--en vez de tam hay que poner pos+tam directamente como constante de hcnt o vcnt
constant tam_number_x: integer := 16;
constant tam_number_y: integer := 32;
constant tam_win_x: integer := 128;
constant tam_win_y: integer := 64;
constant tam_nivel_x: integer := 32;
constant tam_nivel_y: integer := 32;
constant tam_crea_tu_x: integer := 64;
constant tam_crea_tu_y: integer := 32;
constant tam_lose_x: integer := 128;
constant tam_lose_y: integer := 64;
constant tam_flecha_x: integer := 8;
constant tam_flecha_y: integer := 16;
--constant tam_space_invaders_x: integer := 128;
--constant tam_space_invaders_y: integer := 64;


constant fila1: vertical_counter := conv_std_logic_vector(170, tam_v_counter);
constant fila2: vertical_counter := conv_std_logic_vector(178, tam_v_counter);
constant columna1: horizontal_counter := conv_std_logic_vector(5, tam_h_counter);--flecha
constant columna2: horizontal_counter := conv_std_logic_vector(15, tam_h_counter);--nivel
constant columna3: horizontal_counter := conv_std_logic_vector(48, tam_h_counter);--1
constant columna4: horizontal_counter := conv_std_logic_vector(70, tam_h_counter);--flecha
constant columna5: horizontal_counter := conv_std_logic_vector(80, tam_h_counter);--nivel
constant columna6: horizontal_counter := conv_std_logic_vector(113, tam_h_counter);--2
constant columna7: horizontal_counter := conv_std_logic_vector(135, tam_h_counter);--flecha
constant columna8: horizontal_counter := conv_std_logic_vector(145, tam_h_counter);--crea tu
constant columna9: horizontal_counter := conv_std_logic_vector(210, tam_h_counter);--nivel


constant pos_flecha1_x: horizontal_counter := columna1;
constant pos_flecha1_y: vertical_counter := fila2;
constant pos_nivel1_x: horizontal_counter := columna2;
constant pos_nivel1_y: vertical_counter := fila1;
constant pos_uno_x: horizontal_counter := columna3;
constant pos_uno_y: vertical_counter := fila1;
constant pos_flecha2_x: horizontal_counter :=  columna4;
constant pos_flecha2_y: vertical_counter := fila2;
constant pos_nivel2_x: horizontal_counter :=  columna5;
constant pos_nivel2_y: vertical_counter := fila1;
constant pos_dos_x: horizontal_counter :=  columna6;
constant pos_dos_y: vertical_counter := fila1;
constant pos_flecha3_x: horizontal_counter := columna7;
constant pos_flecha3_y: vertical_counter := fila2;
constant pos_nivel3_x: horizontal_counter :=  columna9;
constant pos_nivel3_y: vertical_counter := fila1;
constant pos_crea_tu_x: horizontal_counter :=  columna8;
constant pos_crea_tu_y: vertical_counter := fila1;


constant pos_win_x: horizontal_counter := columna5;
constant pos_win_y: vertical_counter := fila1;
constant pos_lose_x: horizontal_counter := columna5;
constant pos_lose_y: vertical_counter := fila1;
--constant pos_space_invaders_x: horizontal_counter := conv_std_logic_vector(60, tam_h_counter);
--constant pos_space_invaders_y: vertical_counter := conv_std_logic_vector(70, tam_v_counter);





signal addr_nivel: std_logic_vector (9 downto 0);
signal addr_crea_tu: std_logic_vector (10 downto 0);
--signal addr_space_invaders: std_logic_vector (12 downto 0);
signal addr_nivel1, addr_nivel2, addr_nivel3: std_logic_vector (9 downto 0);
signal addr_uno, addr_dos: std_logic_vector (8 downto 0);
signal addr_flecha: std_logic_vector (6 downto 0);
signal addr_win: std_logic_vector(12 downto 0);
signal addr_lose: std_logic_vector(12 downto 0);
signal color_uno, color_dos, color_flecha, color_nivel, color_crea_tu, color_win, 
			color_lose: color_rgb;

signal pintar_uno, pintar_dos, pintar_flecha, pintar_nivel1, pintar_nivel2, pintar_nivel3,
			pintar_win, pintar_lose, pintar_crea_tu: std_logic;

signal est_flecha, sig_est_flecha: estado_flecha;
signal estado, sig_estado: estados_juego;

signal 	dif_h_uno, dif_h_dos, dif_h_flecha1, dif_h_flecha2, dif_h_flecha3, dif_h_nivel1, dif_h_nivel2,
			dif_h_nivel3, dif_h_crea_tu, dif_h_win, dif_h_lose: horizontal_counter; 
signal 	dif_v_uno, dif_v_dos, dif_v_flecha1, dif_v_flecha2, dif_v_flecha3, dif_v_nivel1, dif_v_nivel2,
			dif_v_nivel3, dif_v_crea_tu, dif_v_win, dif_v_lose: vertical_counter; 

--señales de configuracion de nivel
signal set_x, sig_set_x: std_logic_vector (log_columnas_marc-1 downto 0);
signal set_y, sig_set_y: std_logic_vector (log_filas_marc-1 downto 0);
signal matriz_marc, sig_matriz_marc: matriz_id_color;
signal recibe_tecla, sig_recibe_tecla, clk_retardo: std_logic;

begin
	ram_nivel: nivel_ram port map (clk_main, addr_nivel, color_nivel);
	ram_1: uno_ram port map (clk_main, addr_uno, color_uno);
	ram_2: dos_ram port map 
	   (	clk => clk_main,
			addr1 => addr_dos,
			 
         do1 => color_dos
		);
	ram_flecha: flecha_ram port map (clk_main, addr_flecha, color_flecha);
	ram_crea_tu: crea_tu_ram port map (clk_main, addr_crea_tu, color_crea_tu);
	ram_win: win_ram port map (clk_main, addr_win, color_win);
	ram_lose: lose_ram port map (clk_main, addr_lose, color_lose);
	--ram_space_invaders: space_invaders_ram port map (clk_main, addr_space_invaders, color_space_invaders);

	
	retado: cont_retardo_tecla port map (reset, recibe_tecla, clk_fps, clk_retardo);
	
	pintar_pant_ini <= pintar_uno or pintar_dos or pintar_flecha or pintar_nivel1 or pintar_nivel2 or pintar_nivel3
							or pintar_crea_tu or pintar_win or pintar_lose;
	estado_out <= estado;
	
	distr_your_lvl <= matriz_marc;
	set_x_out <= set_x;
	set_y_out <= set_y;
	
	color <= 	color_uno when pintar_uno = '1' else
					color_dos when pintar_dos = '1' else
					color_flecha when pintar_flecha = '1' else
					color_nivel when pintar_nivel1 = '1' else--separado así, sin or a proposito
					color_nivel when pintar_nivel2 = '1' else
					color_nivel when pintar_nivel3 = '1' else
					color_crea_tu when pintar_crea_tu = '1' else
					--color_space_invaders when pintar_space_invaders = '1' else
					color_win when pintar_win = '1' else
					color_lose when pintar_lose = '1' else
					(others => '0');
	
	addr_nivel <= addr_nivel1 when pintar_nivel1 = '1' else
						addr_nivel2 when pintar_nivel2 = '1' else
						addr_nivel3 when pintar_nivel3 = '1' else
						(others => '0');
	dif_h_uno <= hcnt - pos_uno_x;
	dif_v_uno <= vcnt - pos_uno_y;
	dif_h_dos <= hcnt - pos_dos_x;
	dif_v_dos <= vcnt - pos_dos_y;
	dif_h_flecha1 <= hcnt - pos_flecha1_x;
	dif_v_flecha1 <= vcnt - pos_flecha1_y;
	dif_h_flecha2 <= hcnt - pos_flecha2_x;
	dif_v_flecha2 <= vcnt - pos_flecha2_y;
	dif_h_flecha3 <= hcnt - pos_flecha3_x;
	dif_v_flecha3 <= vcnt - pos_flecha3_y;
	dif_h_nivel1 <= hcnt - pos_nivel1_x;
	dif_v_nivel1 <= vcnt - pos_nivel1_y;
	dif_h_nivel2 <= hcnt - pos_nivel2_x;
	dif_v_nivel2 <= vcnt - pos_nivel2_y;
	dif_h_nivel3 <= hcnt - pos_nivel3_x;
	dif_v_nivel3 <= vcnt - pos_nivel3_y;
	dif_h_crea_tu <= hcnt - pos_crea_tu_x;
	dif_v_crea_tu <= vcnt - pos_crea_tu_y;
--	dif_h_space_invaders <= hcnt - pos_space_invaders_x;
--	dif_v_space_invaders <= vcnt - pos_space_invaders_y;
	dif_h_win <= hcnt - pos_win_x;
	dif_v_win <= vcnt - pos_win_y;
	dif_h_lose <= hcnt - pos_lose_x;
	dif_v_lose <= vcnt - pos_lose_y;

	set_color: process (pintar_uno, pintar_dos, pintar_flecha, pintar_nivel1,  pintar_nivel2, pintar_nivel3, pintar_crea_tu, pintar_win, pintar_lose, hcnt, vcnt)
	begin
		
		-- addr <= dif_v(log(tam_v)-1 downto 0) & dif_h(log(tam_h)-1 downto 0);
				
		addr_uno	<= (others => '0');
		addr_dos	<= (others => '0');
		addr_nivel1	<= (others => '0');
		addr_nivel2	<= (others => '0');
		addr_nivel3	<= (others => '0');
		addr_crea_tu <= (others => '0');
		--addr_space_invaders <= (others => '0');
		addr_flecha	<= (others => '0');
		addr_win	<= (others => '0');
		addr_lose <= (others => '0');
		if pintar_uno = '1' then
			addr_uno	<= dif_v_uno(4 downto 0) & dif_h_uno(3 downto 0);--32x16
		elsif pintar_dos = '1' then			
			addr_dos	<= dif_v_dos(4 downto 0) & dif_h_dos(3 downto 0);--32x16
		elsif pintar_flecha = '1' then
		--16x8
			if est_flecha = FLECHA_LVL_1 then
				addr_flecha <= dif_v_flecha1(3 downto 0) & dif_h_flecha1(2 downto 0);
			elsif est_flecha = FLECHA_LVL_2 then
				addr_flecha <= dif_v_flecha2(3 downto 0) & dif_h_flecha2(2 downto 0);
			elsif est_flecha = FLECHA_SET_LVL then
				addr_flecha <= dif_v_flecha3(3 downto 0) & dif_h_flecha3(2 downto 0);
			end if;
		elsif pintar_nivel2 = '1' then
		--32x32
			addr_nivel2	<= dif_v_nivel2(4 downto 0) & dif_h_nivel2(4 downto 0);
		elsif pintar_nivel1 = '1' then
		--32x32
			addr_nivel1	<= dif_v_nivel1(4 downto 0) & dif_h_nivel1(4 downto 0);
		elsif pintar_nivel3 = '1' then
		--32x32
			addr_nivel3	<= dif_v_nivel3(4 downto 0) & dif_h_nivel3(4 downto 0);
		elsif pintar_crea_tu = '1' then
		--32x32
			addr_crea_tu <= dif_v_crea_tu(4 downto 0) & dif_h_crea_tu(5 downto 0);
--		elsif pintar_space_invaders = '1' then
--		--64x128
--			addr_space_invaders <= dif_v_space_invaders(5 downto 0) & dif_h_space_invaders(6 downto 0);
		elsif pintar_win = '1' then
			--64x128
			addr_win <= dif_v_win(5 downto 0) & dif_h_win(6 downto 0);
		elsif pintar_lose = '1' then
			--64x128
			addr_lose <= dif_v_lose(5 downto 0) & dif_h_lose(6 downto 0);
		end if;
	end process;
	
	main: process (reset, clk_vga)
	begin
		if reset = '1' then
			estado <= INIT_SCR;
			est_flecha <= FLECHA_LVL_1;
			set_x <= (others => '0');
			set_y <= (others => '0');
			matriz_marc <=(	(L, L, L, L, L, L),
									(L, L, L, L, L, L),
									(L, L, L, L, L, L)
								);
		elsif clk_vga'event and clk_vga = '1' then
			set_x <= sig_set_x;
			set_y <= sig_set_y;
			estado <= sig_estado;
			est_flecha <= sig_est_flecha;
			matriz_marc <= sig_matriz_marc;
			recibe_tecla <= sig_recibe_tecla;
		end if;
	end process;
	
	next_estado: process (estado, est_flecha)
	begin
		sig_set_x <= set_x;
		sig_set_y <= set_y;
		sig_estado <= estado;
		sig_recibe_tecla <= recibe_tecla;
		sig_matriz_marc <= matriz_marc;
		sig_est_flecha <= est_flecha;
		if recibe_tecla = '0' then
			if clk_retardo = '1' then--comprobar que clk_retardo empieza en '0'
				sig_recibe_tecla <= '1';
			end if;
		elsif estado = INIT_SCR then
			sig_est_flecha <= est_flecha; 	--elimina latches
			sig_estado <= INIT_SCR;				--elimina latches
			if est_flecha = FLECHA_LVL_1 then
				if tecla = DERECHA then
					sig_est_flecha <= FLECHA_LVL_2;
					sig_recibe_tecla <= '0';
				elsif tecla = INTRO then
					sig_estado <= LEVEL1;
					sig_recibe_tecla <= '0';
				end if;
			elsif est_flecha = FLECHA_LVL_2 then
				if tecla = IZQUIERDA then
					sig_est_flecha <= FLECHA_LVL_1;
					sig_recibe_tecla <= '0';
				elsif tecla = DERECHA then
					sig_est_flecha <= FLECHA_SET_LVL;
					sig_recibe_tecla <= '0';
				elsif tecla = INTRO then
					sig_estado <= LEVEL2;
					sig_recibe_tecla <= '0';
				end if;
			elsif est_flecha = FLECHA_SET_LVL then
				if tecla = IZQUIERDA then
					sig_est_flecha <= FLECHA_LVL_2;
					sig_recibe_tecla <= '0';
				elsif tecla = INTRO then
					sig_set_x <= (others => '0');
					sig_set_y <= (others => '0');
					sig_estado <= SET_LEVEL;
					sig_recibe_tecla <= '0';
				end if;
			end if;
		elsif estado = WIN then
			if tecla = INTRO then
				sig_estado <= INIT_SCR;
				sig_recibe_tecla <= '0';
			else
				sig_estado <= WIN;
			end if;
		elsif estado = LOSE then
			if tecla = INTRO then
				sig_estado <= INIT_SCR;
				sig_recibe_tecla <= '0';
			else
				sig_estado <= LOSE;
			end if;
		elsif estado = LEVEL1 or estado = LEVEL2 or estado = YOUR_LEVEL then
			if sin_vidas = '1' or marc_llegan_abajo = '1' then
				sig_estado <= LOSE;
			elsif sin_marc = '1' then
				sig_estado <= WIN;
			else 
				sig_estado <= estado;  --elimina latches
			end if;
		elsif estado = SET_LEVEL then
			if tecla = IZQUIERDA and set_x /= conv_std_logic_vector(columnas_marc-1, log_columnas_marc) then
				sig_set_x <= set_x + 1;
				sig_recibe_tecla <= '0';
			elsif tecla = DERECHA and set_x /= conv_std_logic_vector(0, log_columnas_marc) then
				sig_set_x <= set_x -1;
				sig_recibe_tecla <= '0';
			elsif tecla = ARRIBA and set_y /= conv_std_logic_vector(filas_marc-1, log_filas_marc) then
				sig_set_y <= set_y + 1;
				sig_recibe_tecla <= '0';
			elsif  tecla = ABAJO and set_y /= conv_std_logic_vector(0, log_filas_marc) then
				sig_set_y <= set_y -1;
				sig_recibe_tecla <= '0';
			elsif tecla = DISPARAR then
				sig_recibe_tecla <= '0';
				if matriz_marc (conv_integer(set_y))(conv_integer(set_x)) = L then
					sig_matriz_marc (conv_integer(set_y))(conv_integer(set_x)) <= M;
				elsif matriz_marc (conv_integer(set_y))(conv_integer(set_x)) = M then
					sig_matriz_marc (conv_integer(set_y))(conv_integer(set_x)) <= H;
				elsif matriz_marc (conv_integer(set_y))(conv_integer(set_x)) = H then
					sig_matriz_marc (conv_integer(set_y))(conv_integer(set_x)) <= L;
				end if;
			elsif tecla = INTRO then
				sig_estado <= YOUR_LEVEL;
				sig_recibe_tecla <= '0';
			end if;
		end if;
	end process;

pinta: process(hcnt, vcnt)
begin
	pintar_uno <= '0';
	pintar_dos <= '0';
	pintar_flecha <= '0';
	pintar_nivel1  <= '0';
	pintar_nivel2  <= '0';
	pintar_nivel3  <= '0';
	pintar_crea_tu <= '0';
	--pintar_space_invaders <= '0';
	pintar_win <= '0';
	pintar_lose <= '0';
	if estado = INIT_SCR then
		if hcnt > pos_uno_x and hcnt < pos_uno_x + tam_number_x then
			if vcnt > pos_uno_y and vcnt < pos_uno_y + tam_number_y then
				pintar_uno <= '1';
			end if;
		elsif hcnt > pos_dos_x and hcnt < pos_dos_x + tam_number_x then
			if vcnt > pos_dos_y and vcnt < pos_dos_y + tam_number_y then
				pintar_dos <= '1';
			end if;
		elsif hcnt > pos_nivel1_x and hcnt < pos_nivel1_x + tam_nivel_x then
			if vcnt > pos_nivel1_y and vcnt < pos_nivel1_y + tam_nivel_y then
				pintar_nivel1 <= '1';
			end if;
		elsif hcnt > pos_nivel2_x and hcnt < pos_nivel2_x + tam_nivel_x then
			if vcnt > pos_nivel2_y and vcnt < pos_nivel2_y + tam_nivel_y then
				pintar_nivel2 <= '1';
			end if;
		elsif hcnt > pos_nivel3_x and hcnt < pos_nivel3_x + tam_nivel_x then
			if vcnt > pos_nivel3_y and vcnt < pos_nivel3_y + tam_nivel_y then
				pintar_nivel3 <= '1';
			end if;
		elsif hcnt > pos_crea_tu_x and hcnt < pos_crea_tu_x + tam_crea_tu_x then
			if vcnt > pos_crea_tu_y and vcnt < pos_crea_tu_y + tam_crea_tu_y then
				pintar_crea_tu <= '1';
			end if;
--		elsif hcnt > pos_space_invaders_x and hcnt < pos_space_invaders_x + tam_space_invaders_x then
--			if vcnt > pos_space_invaders_y and vcnt < pos_space_invaders_y + tam_space_invaders_y then
--				pintar_space_invaders <= '1';
--			end if;
		elsif est_flecha = FLECHA_LVL_1 then
			if hcnt > pos_flecha1_x and hcnt < pos_flecha1_x + tam_flecha_x then
				if vcnt > pos_flecha1_y and vcnt < pos_flecha1_y + tam_flecha_y then
					pintar_flecha <= '1';
				end if;
			end if;
		elsif est_flecha = FLECHA_LVL_2 then
			if hcnt > pos_flecha2_x and hcnt < pos_flecha2_x + tam_flecha_x then
				if vcnt > pos_flecha2_y and vcnt < pos_flecha2_y + tam_flecha_y then
					pintar_flecha <= '1';
				end if;
			end if;
		elsif est_flecha = FLECHA_SET_LVL then
			if hcnt > pos_flecha3_x and hcnt < pos_flecha3_x + tam_flecha_x then
				if vcnt > pos_flecha3_y and vcnt < pos_flecha3_y + tam_flecha_y then
					pintar_flecha <= '1';
				end if;
			end if;
		end if;
	elsif estado = WIN then
		if hcnt > pos_win_x and hcnt < pos_win_x + tam_win_x then
			if vcnt > pos_win_y and vcnt < pos_win_y + tam_win_y then
				pintar_win <= '1';
			end if;
		end if;
	elsif estado = LOSE then
		if hcnt > pos_lose_x and hcnt < pos_lose_x + tam_lose_x then
			if vcnt > pos_lose_y and vcnt < pos_lose_y + tam_lose_y then
				pintar_lose <= '1';
			end if;
		end if;
	end if;
end process pinta;

end Behavioral;