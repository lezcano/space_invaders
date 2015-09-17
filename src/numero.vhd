library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity numero is
	port(
			clk: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posición del puntero horizontal 
			vcnt: in vertical_counter;				-- Posición del puntero vertical	
			activos: in std_logic_vector(6 downto 0); 
			inicio_h : in horizontal_counter;
			inicio_v: in vertical_counter;
			
			pintar_numero: out std_logic;			-- Pintar barrera
			color: out color_rgb					-- Color de la barrera
	);
end numero;

architecture Behavioral of numero is

	
	
	-- Señales matriz segmentos
	signal sig_activos : std_logic_vector(6 downto 0);

	-- Señales color
	signal color_a_pintar: color_rgb;
	

begin
color <= color_marcador;


	main_process: process (reset)
	begin
		if reset = '1' then
			sig_activos <= "0111111";
		elsif clk'event and clk = '1' then
			--activos <= sig_activos;
		end if;
	end process main_process;	
	
	pintar: process(hcnt, vcnt) 
	begin
		pintar_numero <= '0';
		if hcnt > inicio_h and hcnt < inicio_h + tam_numero_x then
			if vcnt > inicio_v and vcnt < inicio_v + tam_numero_y then
				if(activos(0) = '1' and hcnt > inicio_h + ancho_segm and hcnt < inicio_h + ancho_segm + largo_segm and vcnt > inicio_v and vcnt < inicio_v + ancho_segm) then
					pintar_numero <= '1';
				end if;
				if(activos(1) = '1' and hcnt > inicio_h + ancho_segm + largo_segm and hcnt < inicio_h + tam_numero_x and vcnt > inicio_v + ancho_segm and vcnt < inicio_v + ancho_segm + largo_segm) then
					pintar_numero <= '1';
				end if;
				if(activos(2) = '1' and hcnt > inicio_h + ancho_segm + largo_segm and hcnt < inicio_h + tam_numero_x and vcnt > inicio_v + ancho_segm + largo_segm + ancho_segm and vcnt < inicio_v + ancho_segm + largo_segm + ancho_segm + largo_segm) then
					pintar_numero <= '1';
				end if;
				if(activos(3) = '1' and hcnt > inicio_h + ancho_segm and hcnt < inicio_h + ancho_segm + largo_segm and vcnt > inicio_v + tam_numero_y - ancho_segm and vcnt < inicio_v + tam_numero_y) then
					pintar_numero <= '1';
				end if;
				if(activos(4) = '1' and hcnt > inicio_h and hcnt < inicio_h + ancho_segm and vcnt > inicio_v + ancho_segm + largo_segm + ancho_segm and vcnt < inicio_v + tam_numero_y - ancho_segm) then
					pintar_numero <= '1';
				end if;
				if(activos(5) = '1' and hcnt > inicio_h and hcnt < inicio_h + ancho_segm and vcnt > inicio_v + ancho_segm and vcnt < inicio_v + ancho_segm + largo_segm) then
					pintar_numero <= '1';
				end if;
				if(activos(6) = '1' and hcnt > inicio_h + ancho_segm and hcnt < inicio_h + ancho_segm + largo_segm and vcnt > inicio_v + ancho_segm + largo_segm and vcnt < inicio_v + ancho_segm + largo_segm + ancho_segm) then
					pintar_numero <= '1';
				end if;
			end if;
		end if;
	end process pintar;
end Behavioral;