library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use work.tipos.all;

entity celda_cod_prior_marc is
	port(
		X: in std_logic;
		
		position: in t_small_int;	
		
		num_disp: in t_small_int;
		
		encontr_primer: in std_logic;
		encontr_pos_disp: in std_logic;
		pos_prim_ant: in t_small_int;
		pos_ult_ant: in t_small_int;
		num_activ_ant: in t_small_int;
		pos_disp_ant: in t_small_int;
		
		encontr_primer_sig: out std_logic;
		encontr_pos_disp_sig: out std_logic;
		pos_prim_sig: out t_small_int;
		pos_ult_sig: out t_small_int;
		num_activ_sig: out t_small_int;
		pos_disp_sig: out t_small_int
	);
end celda_cod_prior_marc;

architecture celda_cod_prior_marc_arch of celda_cod_prior_marc is

begin

pos_disp_sig <= 	position when pos_disp_ant = num_disp and X = '1' and encontr_pos_disp = '0' else 
						pos_disp_ant + 1 when X = '1' and encontr_pos_disp = '0' else
						pos_disp_ant;

encontr_pos_disp_sig <= '1' when encontr_pos_disp = '1' or(pos_disp_ant = num_disp  and X = '1') else
								'0';

main: process (encontr_primer, pos_prim_ant, pos_ult_ant, num_activ_ant, position, X)
begin
	if X = '0' then -- No se modifica
		encontr_primer_sig <= encontr_primer;
		pos_prim_sig <= pos_prim_ant;
		pos_ult_sig <= pos_ult_ant;
		num_activ_sig <= num_activ_ant;
	elsif encontr_primer = '0' then
		encontr_primer_sig <= '1';
		pos_prim_sig <= position;
		pos_ult_sig <= position;
		num_activ_sig <= num_activ_ant + 1;
	else  --encontr_primer = '1'
		encontr_primer_sig <= '1';
		pos_prim_sig <= pos_prim_ant;
		pos_ult_sig <= position;
		num_activ_sig <= num_activ_ant + 1;
	end if;
end process;
end celda_cod_prior_marc_arch;

