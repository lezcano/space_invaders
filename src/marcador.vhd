library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity marcador is
	port(
			clk: in std_logic;
			reset: in std_logic;
			hcnt: in horizontal_counter; 			-- Posición del puntero horizontal 
			vcnt: in vertical_counter;				-- Posición del puntero vertical	
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
end marcador;

architecture Behavioral of marcador is

	component numero is
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
	end component;
	
	constant num_0 : std_logic_vector(6 downto 0) := "0111111";
	signal pintar_num_0: std_logic;
	signal color_num_0: color_rgb;
	
	constant num_1 : std_logic_vector(6 downto 0) := "0111111";
	signal pintar_num_1: std_logic;
	signal color_num_1: color_rgb;
	
	signal num_2 : std_logic_vector(6 downto 0);
	signal pintar_num_2: std_logic;
	signal color_num_2: color_rgb;

	signal num_3 : std_logic_vector(6 downto 0);
	signal pintar_num_3: std_logic;
	signal color_num_3: color_rgb;

	signal num_4 : std_logic_vector(6 downto 0);
	signal pintar_num_4: std_logic;
	signal color_num_4: color_rgb;
	
	signal sig_num_1: std_logic_vector(6 downto 0);
	signal sig_num_2: std_logic_vector(6 downto 0);
	signal sig_num_3: std_logic_vector(6 downto 0);
	signal sig_num_4: std_logic_vector(6 downto 0);
	
	signal pos_unidades_x : horizontal_counter := inicio_marcador_h + conv_std_logic_vector(4*tam_numero_x, tam_h_counter);
	signal pos_decenas_x : horizontal_counter := inicio_marcador_h + conv_std_logic_vector(3*tam_numero_x, tam_h_counter);
	signal pos_centenas_x : horizontal_counter := inicio_marcador_h + conv_std_logic_vector(2*tam_numero_x, tam_h_counter);
	signal pos_ud_millar_x : horizontal_counter := inicio_marcador_h + conv_std_logic_vector(tam_numero_x, tam_h_counter);
	signal pos_dec_millar_x : horizontal_counter := inicio_marcador_h;
	signal pos_marcador_y : vertical_counter := inicio_marcador_v;
	
	signal pos_unidades_x_pant_ini : horizontal_counter := inicio_marcador_h_pant_ini + conv_std_logic_vector(4*tam_numero_x, tam_h_counter);
	signal pos_decenas_x_pant_ini : horizontal_counter := inicio_marcador_h_pant_ini + conv_std_logic_vector(3*tam_numero_x, tam_h_counter);
	signal pos_centenas_x_pant_ini : horizontal_counter := inicio_marcador_h_pant_ini + conv_std_logic_vector(2*tam_numero_x, tam_h_counter);
	signal pos_ud_millar_x_pant_ini : horizontal_counter := inicio_marcador_h_pant_ini + conv_std_logic_vector(tam_numero_x, tam_h_counter);
	signal pos_dec_millar_x_pant_ini : horizontal_counter := inicio_marcador_h_pant_ini;
	signal pos_marcador_y_pant_ini : vertical_counter := inicio_marcador_v_pant_ini;
	
	signal pos_unidades_mostrar : horizontal_counter;
	signal pos_decenas_mostrar : horizontal_counter;
	signal pos_centenas_mostrar : horizontal_counter;
	signal pos_ud_millar_mostrar : horizontal_counter;
	signal pos_dec_millar_mostrar : horizontal_counter;
	signal pos_marcador_v_mostrar :vertical_counter;
	
begin
unidades : numero port map(clk, reset, hcnt,vcnt, num_0, pos_unidades_mostrar, pos_marcador_v_mostrar, pintar_num_0, color_num_0);
decenas : numero port map(clk, reset, hcnt,vcnt, num_1, pos_decenas_mostrar, pos_marcador_v_mostrar, pintar_num_1, color_num_1);
centenas : numero port map(clk, reset, hcnt,vcnt,  num_2, pos_centenas_mostrar, pos_marcador_v_mostrar, pintar_num_2, color_num_2);
ud_millar : numero port map(clk, reset, hcnt,vcnt,  num_3, pos_ud_millar_mostrar, pos_marcador_v_mostrar, pintar_num_3, color_num_3);
dec_millar : numero port map(clk, reset, hcnt,vcnt,  num_4,pos_dec_millar_mostrar, pos_marcador_v_mostrar, pintar_num_4, color_num_4);

color <= color_num_0;

main_process: process (reset)
	begin
		if reset = '1' then
		
		elsif clk'event and clk = '1' then
			 
			if(ptos_2 = conv_std_logic_vector(0,small_int)) then
				num_2 <= "0111111";
			elsif ptos_2 = conv_std_logic_vector(1,small_int) then
				num_2 <= "0000110"; 
			elsif ptos_2 = conv_std_logic_vector(2,small_int) then
				num_2 <= "1011011"; 
			elsif ptos_2 = conv_std_logic_vector(3,small_int) then
				num_2 <= "1001111"; 
			elsif ptos_2 = conv_std_logic_vector(4,small_int) then
				num_2 <= "1100110"; 
			elsif ptos_2 = conv_std_logic_vector(5,small_int) then
				num_2 <= "1101101"; 
			elsif ptos_2 = conv_std_logic_vector(6,small_int) then
				num_2 <= "1111101"; 
			elsif ptos_2 = conv_std_logic_vector(7,small_int) then
				num_2 <= "0000111"; 
			elsif ptos_2 = conv_std_logic_vector(8,small_int) then
				num_2 <= "1111111"; 
			else--if ptos_2 = conv_std_logic_vector(9,small_int) then
				num_2 <= "1100111"; 

			end if;
			
			if(ptos_3 = conv_std_logic_vector(0,small_int)) then
				num_3 <= "0111111";
			elsif ptos_3 = conv_std_logic_vector(1,small_int) then
				num_3 <= "0000110"; 
			elsif ptos_3 = conv_std_logic_vector(2,small_int) then
				num_3 <= "1011011"; 
			elsif ptos_3 = conv_std_logic_vector(3,small_int) then
				num_3 <= "1001111"; 
			elsif ptos_3 = conv_std_logic_vector(4,small_int) then
				num_3 <= "1100110"; 
			elsif ptos_3 = conv_std_logic_vector(5,small_int) then
				num_3 <= "1101101"; 
			elsif ptos_3 = conv_std_logic_vector(6,small_int) then
				num_3 <= "1111101"; 
			elsif ptos_3 = conv_std_logic_vector(7,small_int) then
				num_3 <= "0000111"; 
			elsif ptos_3 = conv_std_logic_vector(8,small_int) then
				num_3 <= "1111111"; 
			else--if ptos_3 = conv_std_logic_vector(9,small_int) then
				num_3 <= "1100111"; 
			end if;
				
			if(ptos_4 = conv_std_logic_vector(0,small_int)) then
				num_4 <= "0111111";
			elsif ptos_4 = conv_std_logic_vector(1,small_int) then
				num_4 <= "0000110"; 
			elsif ptos_4 = conv_std_logic_vector(2,small_int) then
				num_4 <= "1011011"; 
			elsif ptos_4 = conv_std_logic_vector(3,small_int) then
				num_4 <= "1001111"; 
			elsif ptos_4 = conv_std_logic_vector(4,small_int) then
				num_4 <= "1100110"; 
			elsif ptos_4 = conv_std_logic_vector(5,small_int) then
				num_4 <= "1101101"; 
			elsif ptos_4 = conv_std_logic_vector(6,small_int) then
				num_4 <= "1111101"; 
			elsif ptos_4 = conv_std_logic_vector(7,small_int) then
				num_4 <= "0000111"; 
			elsif ptos_4 = conv_std_logic_vector(8,small_int) then
				num_4 <= "1111111"; 
			else--if ptos_4 = conv_std_logic_vector(9,small_int) then
				num_4 <= "1100111"; 
			end if;
		
		end if;
end process main_process;	


posicion: process(estado_juego)
begin
	if estado_juego = WIN or estado_juego = LOSE then
		pos_unidades_mostrar <= pos_unidades_x_pant_ini;
		pos_decenas_mostrar <= pos_decenas_x_pant_ini;
		pos_centenas_mostrar <= pos_centenas_x_pant_ini;
		pos_ud_millar_mostrar <= pos_ud_millar_x_pant_ini;
		pos_dec_millar_mostrar <= pos_dec_millar_x_pant_ini;
		pos_marcador_v_mostrar <= pos_marcador_y_pant_ini;
	else
		pos_unidades_mostrar <= pos_unidades_x;
		pos_decenas_mostrar <= pos_decenas_x;
		pos_centenas_mostrar <= pos_centenas_x;
		pos_ud_millar_mostrar <= pos_ud_millar_x;
		pos_dec_millar_mostrar <= pos_dec_millar_x;
		pos_marcador_v_mostrar <= pos_marcador_y;
	end if;
end process;

pintar: process(hcnt, vcnt) 
	begin
		pintar_0 <= '0';
		pintar_1 <= '0';
		pintar_2 <= '0';
		pintar_3 <= '0';
		pintar_4 <= '0';
		
		if(num_a_mostrar = conv_std_logic_vector(1,small_int)) then
			pintar_0 <= pintar_num_0;
		elsif(num_a_mostrar = conv_std_logic_vector(2,small_int)) then
			pintar_0 <= pintar_num_0;
			pintar_1 <= pintar_num_1;
		elsif(num_a_mostrar = conv_std_logic_vector(3,small_int)) then 
			pintar_0 <= pintar_num_0;
			pintar_1 <= pintar_num_1;
			pintar_2 <= pintar_num_2;
		elsif(num_a_mostrar = conv_std_logic_vector(4,small_int)) then
			pintar_0 <= pintar_num_0;
			pintar_1 <= pintar_num_1;
			pintar_2 <= pintar_num_2;
			pintar_3 <= pintar_num_3;
		elsif(num_a_mostrar = conv_std_logic_vector(5,small_int)) then
			pintar_0 <= pintar_num_0;
			pintar_1 <= pintar_num_1;
			pintar_2 <= pintar_num_2;
			pintar_3 <= pintar_num_3;
			pintar_4 <= pintar_num_4;
		end if;
end process pintar;


end Behavioral;