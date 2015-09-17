library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity rand_mod is
	port (
		clk: in std_logic;
		reset: in std_logic;
		num_col_act: std_logic_vector(log_columnas_marc-1 downto 0);
		seed: in std_logic_vector(127 downto 0);
		inicio: in std_logic;
		retardo: in std_logic;
		
		modulo: out std_logic_vector(log_columnas_marc-1 downto 0)
	);
end rand_mod;

architecture Behavioral of rand_mod is


component rng_128 is
	port (
		clk, reset: in std_logic;
		seed: in std_logic_vector(127 downto 0);
		rnumber: out std_logic_vector(31 downto 0)
	);
end component rng_128;

component maquina_divisor is
	generic (N: integer :=32; log_N: integer:= 5; M: integer :=4);
	
	port (
		divisor: in std_logic_vector(M-1 downto 0);
		dividendo: in std_logic_vector(N-1 downto 0);
		inicio: in std_logic;
		reset: in std_logic;
		clk: in std_logic;
		
		resto: out std_logic_vector (M-1 downto 0)
	);
end component maquina_divisor;

	signal r_number:  std_logic_vector(31 downto 0);
	signal resto:  std_logic_vector (log_columnas_marc-1 downto 0);
	signal puede_inicio, sig_puede_inicio, inicio_real: std_logic;
begin
	random: rng_128 port map (retardo, reset, seed, r_number);
	modu: maquina_divisor 
					generic map (	N => 32,
									log_N => 5,
									M => log_columnas_marc)
					port map(num_col_act, r_number, inicio_real, reset, clk, resto);
	pr_main: process (clk, reset)
	begin
		if reset = '1' then
			puede_inicio <= '0';
		elsif clk'event and clk = '1' then 
			puede_inicio <= sig_puede_inicio;
		end if;
	end process pr_main;
	
	sig_puede_inicio <= not inicio;
	
	inicio_real <= '0' 	when num_col_act = conv_std_logic_vector (1, log_columnas_marc)
								or num_col_act = conv_std_logic_vector (2, log_columnas_marc) else		
						puede_inicio and inicio;
	
	modulo <= 	conv_std_logic_vector (0, log_columnas_marc) 					when num_col_act = conv_std_logic_vector (1, log_columnas_marc) else
					conv_std_logic_vector (0, log_columnas_marc-1) & r_number (0)	when num_col_act = conv_std_logic_vector (2, log_columnas_marc) else		
					resto;
end Behavioral;