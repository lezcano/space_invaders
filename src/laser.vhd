-- Implementa una versión básica de un disparo laser que se irá moviendo con cierta velocidad.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity laser is
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
end laser;


architecture laser_arch of laser is

-- Tipos Laser
type estado_laser is (ACTIVADO, DESACTIVADO);



-- Declaracion de señales laser.
signal pos_x: horizontal_counter;
signal sig_pos_x: horizontal_counter;
signal pos_y: vertical_counter;
signal sig_pos_y: vertical_counter;
signal estado: estado_laser;
signal sig_estado: estado_laser;

begin

-- El color del laser serÃ¡ independiente de su posiciÃ³n
color<= laser_color;


-- Pasa al siguiente estado del disparo y actualiza la posición coherentemente
pr_fps: process (clk_fps, reset,pos_ini_x, pos_ini_y, estado_juego)
begin
	if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
		and estado_juego /= YOUR_LEVEL)  then
		pos_x <= pos_ini_x; 
		pos_y <= pos_ini_y;
	elsif (clk_fps'event and clk_fps='1') then
		pos_y <= sig_pos_y;
		pos_x <= sig_pos_x;
		
	end if;
end process pr_fps;

pr_vga: process (clk_vga, reset, estado_juego)
begin
	if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2
		and estado_juego /= YOUR_LEVEL)  then
		estado <= DESACTIVADO;	
	elsif (clk_vga'event and clk_vga = '1') then
		estado <= sig_estado;
	end if;
end process pr_vga;

-- Calcula el siguiente estado
next_estado: process (estado, activa_laser, desactiva_laser, pos_y)
begin
	if desactiva_laser = '1' then -- Va a ir con un ciclo del clock_vga de retraso.
		sig_estado <= DESACTIVADO;
	elsif estado = DESACTIVADO and activa_laser = '1' then
		sig_estado <= ACTIVADO;
	elsif estado = ACTIVADO then
		if pos_y > min_screen_y and pos_y < max_screen_y and
			pos_x > min_screen_x and pos_x < max_screen_x - tam_laser_x then
				sig_estado <= ACTIVADO;
		else
			sig_estado <= DESACTIVADO;
		end if;
	else --si entra en este else es porque estado = DESACTIVADO y activa laser es '0'
		sig_estado <= estado;  -- Elimina Latches¡
	end if;
end process next_estado;

-- Calcula la siguiente posicion
next_pos: process (pos_x, pos_y, activa_laser, estado, pos_ini_x, pos_ini_y, laser_speed_x, laser_speed_y)
begin
   if estado = ACTIVADO then
		sig_pos_y <= pos_y - laser_speed_y; --es menos porque la numeracion de la pantalla va hacia abajo
		sig_pos_x <= pos_x + laser_speed_x;
	else  --estado = DESACTIVADO then
		sig_pos_x <= pos_ini_x; 
		sig_pos_y <= pos_ini_y;
	end if;
end process next_pos;

-- Pinta el disparo
pinta: process(hcnt, vcnt, estado, pos_x, pos_y) -- estado, pos_x, pos_y quitan latches
begin
	pinta_laser<='0';
	if estado = ACTIVADO then 
		if hcnt > pos_x and hcnt < pos_x + tam_laser_x then
			if vcnt > pos_y and vcnt < pos_y + tam_laser_y then
				pinta_laser<='1';
			end if;
		end if;
	end if;
end process pinta;

end laser_arch;

