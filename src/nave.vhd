-- VersiÃ³n simple de la nave que se mueve a izqda y drcha con el teclado

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity nave is
	port(	
			clk_fps: in std_logic;
			clk_vga: in std_logic;
			clk_main: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posición del puntero horizontal 
			vcnt: in vertical_counter;				-- Posición del puntero vertical	
			accion_nave: in accion;
			estado_juego: in estados_juego;
			colision_nave: in std_logic;
			
			pintar_nave: out std_logic;			-- Pintar nave
			color: out color_rgb;					-- Color de la nave
			pos_x_out: out horizontal_counter;	-- Posicion horizontal para posición inicial del laser al disparar
			pos_y_out: out vertical_counter;	-- Posicion vertical para posición inicial del laser al disparar
			vida_out: out std_logic_vector;
			nave_muerta: out std_logic		
		);
end nave;


architecture nave_arch of nave is

component nave_dib is
    port (clk 		:	in std_logic;
          addr1 	:	in std_logic_vector(7 downto 0);
			 
          do1 : out std_logic
	);
end component nave_dib;

-- Posicion inicial de la nave y por el momento altura fija
constant inicio_v: vertical_counter := conv_std_logic_vector(360, tam_v_counter);
constant inicio_h: horizontal_counter := conv_std_logic_vector(140, tam_h_counter);

-- Límites precalculados para saber si va a chocar la nave en el siguiente estado.
constant limite_iz: integer := min_screen_x + nave_speed;
constant limite_der: integer := max_screen_x - tam_nave_x - nave_speed;
constant limite_arr: integer := min_screen_y + nave_speed;
constant limite_aba: integer := max_screen_y - tam_nave_y - nave_speed;

-- Posición que se le asigna a la nave en el caso de chocar con el lateral derecho e inferior
constant dif_borde_x: integer := max_screen_x - tam_nave_x;
constant dif_borde_y: integer := max_screen_y - tam_nave_y; 

-- Color Nave
constant nave_color1: color_rgb := "111001010"; --rojo_nave
constant nave_color2: color_rgb := "000110101"; --azul_marco
constant nave_color3: color_rgb := "010101010"; --verde_marciano
--vida inicial
constant vida_inicial: std_logic_vector (1 downto 0) := "11";

-- Colores
signal addr_color: std_logic_vector(7 downto 0);
signal dif_v: vertical_counter;
signal dif_h: horizontal_counter;

-- Señales de la posicion de la nave
signal pos_x: horizontal_counter;
signal pos_y: vertical_counter;
signal sig_pos_x: horizontal_counter;
signal sig_pos_y: vertical_counter;

--vida de la nave
signal vida: std_logic_vector (1 downto 0);
signal sig_vida: std_logic_vector (1 downto 0);

-- Señales Pintar
signal pinta_nave, pinta_nave_dib: std_logic;

begin
pos_x_out <= pos_x;
pos_y_out <= pos_y;
vida_out <= vida;
pintar_nave <= pinta_nave and pinta_nave_dib;

with vida select
color <= nave_color3 when "11",
			nave_color2 when "10",
			nave_color1 when "01",
			"101010101" when others; -- 00

with vida select
nave_muerta <= '1' when "00",
					'0' when others;

dif_h <= hcnt - pos_x;
dif_v <= vcnt - pos_y;
addr_color <= dif_v(3 downto 0) & dif_h(3 downto 0);

nave_div_ram: nave_dib port map (clk_main, addr_color, pinta_nave_dib);


pr_fps: process (clk_fps, reset, estado_juego)
begin
	if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
		and estado_juego /= YOUR_LEVEL)  then
		pos_x <= inicio_h; 
		pos_y <= inicio_v;
	elsif (clk_fps'event and clk_fps='1') then
		pos_x <= sig_pos_x;
		pos_y <= sig_pos_y;
	end if;
end process pr_fps;

pr_vga: process (clk_vga, reset)
begin
	if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
		and estado_juego /= YOUR_LEVEL)  then
		vida <= vida_inicial;
	elsif (clk_vga'event and clk_vga = '1') then
		vida <= sig_vida;
	end if;
end process pr_vga;

next_pos: process (accion_nave, pos_x, pos_y)
begin
	sig_pos_y <= pos_y;
	sig_pos_x <= pos_x;
	if accion_nave = DERECHA then
		sig_pos_y <= pos_y; --elimina latches
		if pos_x < limite_der then
			sig_pos_x <= pos_x + nave_speed;
		else
			sig_pos_x <= conv_std_logic_vector(dif_borde_x, tam_h_counter); --Se ha hecho para que la nave no llegue a tocar el borde.
		end if;
		
	elsif accion_nave = IZQUIERDA then
		
		sig_pos_y <= pos_y; --elimina latches
		if pos_x > limite_iz then
			sig_pos_x <= pos_x - nave_speed;
		else
			sig_pos_x <= conv_std_logic_vector(min_screen_x, tam_h_counter);
		end if;
		
	--end if;	
	-- Descomentar arriba y comentar abajo para desactivar movimiento vertical	
	elsif accion_nave = ARRIBA then
		
		sig_pos_x <= pos_x; --elimina latches
		if pos_y > limite_arr then
			sig_pos_y <= pos_y - nave_speed;
		else
			sig_pos_y <= conv_std_logic_vector(min_screen_y, tam_v_counter);
		end if;
		
	elsif accion_nave = ABAJO then 

		sig_pos_x <= pos_x; --elimina latches
		if pos_y  < limite_aba	then 
			sig_pos_y <= pos_y + nave_speed;
		else
			sig_pos_y <= conv_std_logic_vector(dif_borde_y, tam_v_counter);
		end if;
		
	else
		sig_pos_y <= pos_y;
		sig_pos_x <= pos_x; 
	end if;
end process next_pos;

calc_vida: process (colision_nave, vida)
begin
	if unsigned(vida) /= 0 and colision_nave = '1' then
		sig_vida <= vida - 1 ;
	else
		sig_vida <= vida;
	end if;
end process calc_vida;

pintar: process(hcnt, vcnt, pos_x, pos_y) -- Pos_x y pos_y estan para quitar warnings
begin
	pinta_nave <= '0';
	if hcnt > pos_x and hcnt < pos_x + tam_nave_x then
		if vcnt > pos_y and vcnt < pos_y + tam_nave_y then
			pinta_nave <= '1';
		end if;
	end if;
end process pintar;

end nave_arch;

