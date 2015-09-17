library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use work.tipos.all;

entity maquina_divisor is
	generic (N: integer :=32; log_N: integer:= 5; M: integer :=4);
	
	port (
		divisor: in std_logic_vector(M-1 downto 0);
		dividendo: in std_logic_vector(N-1 downto 0);
		inicio: in std_logic;
		reset: in std_logic;
		clk: in std_logic;
		
		resto: out std_logic_vector (M-1 downto 0)
	);
end maquina_divisor;

architecture Behavioral of maquina_divisor is

type state is (s0, s1, s2, s3, s4, s5);

constant dif: integer := N-M;

--esto es para concatenar ceros en la asignacion del s1
constant aux: std_logic_vector (dif-1 downto 0) := (others => '0');

signal Rdnd, Rdsor, sig_Rdnd, sig_Rdsor: std_logic_vector (N downto 0);
signal Rk, sig_Rk: std_logic_vector (log_N-1 downto 0);
signal CMP: std_logic;
signal estado, sig_estado: state;
signal div_aux, sig_div_aux: std_logic_vector(N-1 downto 0);

begin

resto <= Rdnd(M-1 downto 0);

sinc: process (reset, clk)
begin
	if reset = '1' then
		estado <= s0;
		Rdnd <= (others =>'0');
		Rdsor <= (others =>'0');
		Rk <= (others =>'0');
		div_aux <= (others => '0');
	elsif clk'event and clk = '1' then
		estado <= sig_estado;
		Rdnd <= sig_Rdnd;
		Rdsor <= sig_Rdsor;
		Rk <= sig_Rk;
	end if;
end process sinc;


comp: process (Rk)
begin
	if Rk > conv_std_logic_vector(dif, log_N) then
		CMP <= '0';
	else
		CMP <= '1';
	end if;
end process comp;

comb: process (estado, dividendo, divisor, Rdsor, Rdnd, Rk,inicio, CMP)
begin
	sig_Rdnd <= Rdnd;
	sig_Rdsor <= Rdsor;
	sig_Rk <= Rk;
	sig_div_aux <= div_aux;
	if estado = s0 then
		if inicio = '0' or dividendo = div_aux then
			sig_estado <= s0;
		else
			sig_estado <= s1;
			sig_div_aux <= dividendo;
		end if;
	elsif estado = s1 then
		sig_Rdnd <= '0' & dividendo;
		sig_Rdsor <= '0' & divisor & aux;
		sig_Rk <= (others => '0');
		sig_estado <= s2;
	elsif estado = s2 then
		sig_Rdnd <= Rdnd - Rdsor;
		sig_estado <= s3;
	elsif estado = s3 then
		if Rdnd (N) = '1' then
			sig_Rdnd <= Rdnd + Rdsor;
		else
			sig_Rdnd <= Rdnd; --elimina latches
		end if;
		sig_estado <= s4;
	elsif estado = s4 then
		sig_Rk <= Rk + 1;
		sig_estado <= s5;
	elsif estado = s5 then
		sig_Rdsor <= '0' & Rdsor (N downto 1);
		if CMP = '1' then
			sig_estado <= s2;
		else 
			sig_estado <= s0;
		end if;
	end if;
end process;

end Behavioral;