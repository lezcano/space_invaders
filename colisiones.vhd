library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

-- Está hecho de tal manera que los marcianos no colisionan con laseres de otros marcianos.
--No se deberia dar el caso (a menos que en un término extremo, un marciano de la fila de
--arriba dispare, la matriz se mueva y le dé al marciano de la fila de abajo de la columna contigua)
--Pero en el caso en que se da, el láser simplemente atravesará al marciano

--Suponemos que la nave nunca se puede chocar con los laseres que ella misma dispara (comprobar velocidades)
--La nave se choca con los láseres y los Marcianos.

--En teoría también se supone que no va a haber colisiones de más de dos elementos.

entity colision_lvl_1 is
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
end colision_lvl_1;

architecture colision_lvl_1_arch of colision_lvl_1 is
begin
			colision_nave <= 	is_nave and (is_laser_marciano or is_marciano);
			colision_laser <= is_laser and (is_marciano or is_laser_marciano or is_barrera_1 or is_barrera_2 or is_barrera_3);
			colision_marciano <=	is_marciano and (is_laser or is_nave);
			colision_laser_marciano <=	is_laser_marciano and (is_nave or is_laser or is_barrera_1 or is_barrera_2 or is_barrera_3);
			colision_barrera_1 <= (is_laser_marciano or is_laser) and is_barrera_1;
			colision_barrera_2 <= (is_laser_marciano or is_laser) and is_barrera_2;
			colision_barrera_3 <= (is_laser_marciano or is_laser) and is_barrera_3;
end colision_lvl_1_arch;