library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity marciano is
	port(
		clk_vga: in std_logic;
		reset: in std_logic;
		hcnt: in horizontal_counter;
		vcnt: in vertical_counter;
		estado_juego: in estados_juego;
		tipo_marc: in colores_marc;
		pos_x: in horizontal_counter;
		pos_y: in vertical_counter;
		golpeado: in std_logic;
		inicio_matriz: in std_logic;
		
		activo_out: out std_logic;
		vida_out : out std_logic_vector (1 downto 0);
		marc_activo: out std_logic;
		pintar_marc: out std_logic
	);
end marciano;



architecture Behavioral of marciano is

--vida inicial
constant vida_inicial_debil: std_logic_vector (1 downto 0):= "01";
constant vida_inicial_fuerte: std_logic_vector (1 downto 0):= "11";

--vida de la nave
signal vida: std_logic_vector (1 downto 0);
signal sig_vida: std_logic_vector (1 downto 0);
signal activado: std_logic;

--debug
signal sig_activo, activo: std_logic;
begin
	
	activo_out <= activo;

	vida_out <= vida;
	
	update_vida: process (clk_vga, reset)
	begin
		if reset = '1' or (estado_juego /= LEVEL1 and estado_juego /= LEVEL2 and
			estado_juego /= YOUR_LEVEL and estado_juego /= SET_LEVEL	) or inicio_matriz = '1' then
			--EN TEORIA LA CONDICION DE ARRIBA FUNCIONA SIN EL SEGUNDO OPERANDO, EL QUE ESTÁ ENTRE PARÉNTESIS
			if tipo_marc = H then
				vida <= vida_inicial_fuerte;
			else
				vida <= vida_inicial_debil;
			end if;
			activo <= '0';
		elsif (clk_vga'event and clk_vga = '1') then
			vida <= sig_vida;
			activo <= sig_activo;
		end if;
	end process update_vida;
	
	marc_activo <= activado;
	
	with vida select
	activado <= '0' when "00",
					'1' when others;

	
	calc_vida: process (golpeado, vida)
	begin
		if unsigned(vida) /= 0 and golpeado = '1' then
			sig_vida <= vida - 1 ;
		else
			sig_vida <= vida;
		end if;
	end process calc_vida;

	
	pintar: process(hcnt, vcnt, pos_x, pos_y, activado) -- Elimina warnings
	begin
		pintar_marc<='0';
		sig_activo <= activo;
		if activado = '1' then
			if hcnt > pos_x and hcnt < pos_x + tam_marc_x then
				if vcnt > pos_y and vcnt < pos_y + tam_marc_y then
					pintar_marc <= '1';
					sig_activo <= '1';
				end if;
			end if;
		end if;
	end process pintar;

end Behavioral;

