library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity sumador_puntos is
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
end sumador_puntos;

architecture Behavioral of sumador_puntos is
	signal cuenta, sig_cuenta : t_small_int;
	signal num_2, num_3, num_4 : t_small_int;
	signal sig_num_2, sig_num_3, sig_num_4 : t_small_int;
begin
	num_2_out <= num_2;
	num_3_out <= num_3;
	num_4_out <= num_4;
	
	num_a_mostrar_out <= conv_std_logic_vector(5,small_int) when sig_num_4 /= 0 else
								conv_std_logic_vector(4,small_int) when sig_num_3 /= 0 else
								conv_std_logic_vector(3,small_int) when sig_num_2 /= 0 else
								conv_std_logic_vector(1,small_int);
	
	main_process: process (clk,reset)
		begin
			if reset = '1' or estado_juego = INIT_SCR then
				num_2 <= (others => '0');
				num_3 <= (others => '0');
				num_4 <= (others => '0');
				cuenta <= (others => '0');
			elsif clk'event and clk = '1' then			
				num_2 <= sig_num_2;
				num_3 <= sig_num_3;
				num_4 <= sig_num_4;
				cuenta <= sig_cuenta;
			end if;
	end process main_process;	

	coger_numero: process(numero, cuenta, sig_cuenta)
	begin
		if(numero /= conv_std_logic_vector(0,small_int)) then
			sig_cuenta <= numero;
		elsif cuenta = conv_std_logic_vector(0,small_int) then
			sig_cuenta <= (others => '0');
		else
			sig_cuenta <= cuenta - 1;
		end if;
	end process coger_numero;
	
	act_numeros: process(numero, sig_num_2, sig_num_3, sig_num_4, cuenta)
	begin	
		sig_num_2 <= num_2;
		sig_num_3 <= num_3;
		sig_num_4 <= num_4;
		
		if cuenta /= 0 then
			if (num_2 /= conv_std_logic_vector(9,small_int)) then
				sig_num_2 <= num_2 + 1;
			else
				sig_num_2 <= (others => '0');
				if(num_3 /= conv_std_logic_vector(9,small_int)) then
					sig_num_3 <= num_3 + 1;
				else 
					sig_num_3 <= (others => '0');
					sig_num_4 <= num_4 + 1;
				end if;
			end if;
		end if;
	end process act_numeros;
end Behavioral;