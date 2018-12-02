library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.fixed_float_types.all;



entity linealizacion_del_termistor is
      port(
		     clk: in std_logic;
			  Vo: in std_logic_vector(11 downto 0);
			  empezar: out std_logic:='0';
			  lectura_adc: in std_logic;
			  fin: out std_logic:='0';
			  d : out std_logic_vector(9 downto 0):= (others => '0');
			  e : out std_logic_vector(7 downto 0):= (others => '0')
			  );

end linealizacion_del_termistor; 

architecture Behavioral of linealizacion_del_termistor is

    signal Tim: ufixed(7 downto -8);
	 signal Tin: ufixed(7 downto -8);
	 
	 signal Vom: ufixed(3 downto -10);
	 signal Von: ufixed(3 downto -10); 
	 
	 signal Tinm: ufixed(8 downto -8);
	 signal Vonm: ufixed(4 downto -10);
	 signal Voim: ufixed(4 downto -10);
	 signal TVd: ufixed(18 downto -13);
	 signal TVm: ufixed(23 downto -23);	 
	   
    constant Ti1: ufixed(7 downto -8) := to_ufixed(15,7,-8);
	 constant Ti2: ufixed(7 downto -8) := to_ufixed(17.5,7,-8);
	 constant Ti3: ufixed(7 downto -8) := to_ufixed(20,7,-8);
	 constant Ti4: ufixed(7 downto -8) := to_ufixed(22.5,7,-8);
	 constant Ti5: ufixed(7 downto -8) := to_ufixed(25,7,-8);
	 constant Ti6: ufixed(7 downto -8) := to_ufixed(27.5,7,-8);
	 constant Ti7: ufixed(7 downto -8) := to_ufixed(30,7,-8);
	 constant Ti8: ufixed(7 downto -8) := to_ufixed(32.5,7,-8);
	 constant Ti9: ufixed(7 downto -8) := to_ufixed(35,7,-8);
	 constant Ti10: ufixed(7 downto -8) := to_ufixed(37.5,7,-8);
	 constant Ti11: ufixed(7 downto -8) := to_ufixed(40,7,-8);
	 constant Ti12: ufixed(7 downto -8) := to_ufixed(42.5,7,-8);
	 constant Ti13: ufixed(7 downto -8) := to_ufixed(45,7,-8);
	 constant Ti14: ufixed(7 downto -8) := to_ufixed(47.5,7,-8);
	 constant Ti15: ufixed(7 downto -8) := to_ufixed(50,7,-8);
	 constant Ti16: ufixed(7 downto -8) := to_ufixed(52.5,7,-8);
	 constant Ti17: ufixed(7 downto -8) := to_ufixed(55,7,-8);
	 constant Ti18: ufixed(7 downto -8) := to_ufixed(57.5,7,-8);
	 constant Ti19: ufixed(7 downto -8) := to_ufixed(60,7,-8);
	 constant Ti20: ufixed(7 downto -8) := to_ufixed(62.5,7,-8);
	 
    constant Vo1: ufixed(3 downto -10) := to_ufixed(0.837,3,-10);
	 constant Vo2: ufixed(3 downto -10) := to_ufixed(0.900,3,-10);
	 constant Vo3: ufixed(3 downto -10) := to_ufixed(0.965,3,-10);
	 constant Vo4: ufixed(3 downto -10) := to_ufixed(1.032,3,-10);
	 constant Vo5: ufixed(3 downto -10) := to_ufixed(1.100,3,-10);
	 constant Vo6: ufixed(3 downto -10) := to_ufixed(1.170,3,-10);
	 constant Vo7: ufixed(3 downto -10) := to_ufixed(1.240,3,-10);---
	 constant Vo8: ufixed(3 downto -10) := to_ufixed(1.309,3,-10);---
	 constant Vo9: ufixed(3 downto -10) := to_ufixed(1.381,3,-10); 
	 constant Vo10: ufixed(3 downto -10) := to_ufixed(1.452,3,-10);
	 constant Vo11: ufixed(3 downto -10) := to_ufixed(1.524,3,-10);
	 constant Vo12: ufixed(3 downto -10) := to_ufixed(1.595,3,-10);
	 constant Vo13: ufixed(3 downto -10) := to_ufixed(1.664,3,-10);
	 constant Vo14: ufixed(3 downto -10) := to_ufixed(1.734,3,-10);
	 constant Vo15: ufixed(3 downto -10) := to_ufixed(1.800,3,-10);
	 constant Vo16: ufixed(3 downto -10) := to_ufixed(1.867,3,-10);
	 constant Vo17: ufixed(3 downto -10) := to_ufixed(1.931,3,-10);
	 constant Vo18: ufixed(3 downto -10) := to_ufixed(1.994,3,-10);
	 constant Vo19: ufixed(3 downto -10) := to_ufixed(2.055,3,-10);
	 constant Vo20: ufixed(3 downto -10) := to_ufixed(2.114,3,-10);
	 
	 constant Kp: ufixed(0 downto -21):=to_ufixed(0.00080586,0,-21);--3.3/2^12=3.3/4096
	 constant Ke: ufixed(9 downto 0):= to_ufixed(1000,9,0);
	 --constant Tref: ufixed(7 downto -1):= to_ufixed(30,7,-1);--ya no
	 constant Tmax: ufixed(7 downto -8):= to_ufixed(34,7,-8);
	 constant offset: ufixed(0 downto -12) := to_ufixed(0.75,0,-12);
	 --constant offTmin: ufixed(0 downto -12) := to_ufixed(1.895,0,-12);--tampoco
	 constant Tmin: ufixed(7 downto -8) := to_ufixed(33.1,7,-8);
	 
	 type type_state is (si,s0,s1,s2,s3,s4,s5,s6);
	 signal state: type_state; 
	 signal Ti: ufixed(7 downto -8);
	 signal eTi: ufixed(7 downto 0);
	 signal dTi: ufixed(9 downto 0);
    --signal Vof: ufixed(3 downto -8);	 

begin
        process(Vo,clk)
          variable Vof: ufixed(3 downto -10);
			 variable permiso: std_logic:='0';
			 		 
		  begin 
			 
			   if clk'event and clk='1' then
			    
				    case state is
					 
					   when si=>  if lectura_adc='1' then
						           Vof := resize(Kp*to_ufixed(Vo,11,0),3,-10);
									  empezar<= '1';
						           state<= s0;	
                             else state<= si; end if;									  
				      
	               when s0 => if Vo1<=Vof and Vof<=Vo2 then
                                Tim<= Ti1;
                                Tin<= Ti2;
 										  Vom<= Vo1;
										  Von<= Vo2;	                          
									  
                             elsif Vo2<Vof and Vof<=Vo3 then
									     Tim<= Ti2;
                                Tin<= Ti3;
 										  Vom<= Vo2;
										  Von<= Vo3;
									  
									  elsif Vo3<Vof and Vof<=Vo4 then
									     Tim<= Ti3;
                                Tin<= Ti4;
 										  Vom<= Vo3;
										  Von<= Vo4;
									  									  
									  elsif Vo4<Vof and Vof<=Vo5 then
									     Tim<= Ti4;
                                Tin<= Ti5;
 										  Vom<= Vo4;
										  Von<= Vo5;
									  									  
									  elsif Vo5<Vof and Vof<=Vo6 then
									     Tim<= Ti5;
                                Tin<= Ti6;
 										  Vom<= Vo5;
										  Von<= Vo6;
									  									  
                             elsif Vo6<Vof and Vof<=Vo7 then
									     Tim<= Ti6;
                                Tin<= Ti7;
 										  Vom<= Vo6;
										  Von<= Vo7;
									                            	  								  
             					  elsif Vo7<Vof and Vof<=Vo8 then
									     Tim<= Ti7;
                                Tin<= Ti8;
 										  Vom<= Vo7;
										  Von<= Vo8;
									                               									  
                             elsif Vo8<Vof and Vof<=Vo9 then
									     Tim<= Ti8;
                                Tin<= Ti9;
 										  Vom<= Vo8;
										  Von<= Vo9;
									                              
                             elsif Vo9<Vof and Vof<=Vo10 then
									     Tim<= Ti9;
                                Tin<= Ti10;
 										  Vom<= Vo9;
										  Von<= Vo10;
									                               
                             elsif Vo10<Vof and Vof<=Vo11 then
									     Tim<= Ti10;
                                Tin<= Ti11;
 										  Vom<= Vo10;
										  Von<= Vo11;
									  elsif Vo11<Vof and Vof<=Vo12 then
									     Tim<= Ti11;
                                Tin<= Ti12;
 										  Vom<= Vo11;
										  Von<= Vo12;
									  elsif Vo12<Vof and Vof<=Vo13 then
									     Tim<= Ti12;
                                Tin<= Ti13;
 										  Vom<= Vo12;
										  Von<= Vo13;
									  elsif Vo13<Vof and Vof<=Vo14 then
									     Tim<= Ti13;
                                Tin<= Ti14;
 										  Vom<= Vo13;
										  Von<= Vo14;
									  elsif Vo14<Vof and Vof<=Vo15 then
									     Tim<= Ti14;
                                Tin<= Ti15;
 										  Vom<= Vo14;
										  Von<= Vo15;
									  elsif Vo15<Vof and Vof<=Vo16 then
									     Tim<= Ti15;
                                Tin<= Ti16;
 										  Vom<= Vo15;
										  Von<= Vo16;
									  elsif Vo16<Vof and Vof<=Vo17 then
									     Tim<= Ti16;
                                Tin<= Ti17;
 										  Vom<= Vo16;
										  Von<= Vo17;
									  elsif Vo17<Vof and Vof<=Vo18 then
									     Tim<= Ti17;
                                Tin<= Ti18;
 										  Vom<= Vo17;
										  Von<= Vo18;
									  elsif Vo18<Vof and Vof<=Vo19 then
									     Tim<= Ti18;
                                Tin<= Ti19;
 										  Vom<= Vo18;
										  Von<= Vo19;
									  elsif Vo19<Vof and Vof<=Vo20 then
									     Tim<= Ti19;
                                Tin<= Ti20;
 										  Vom<= Vo19;
										  Von<= Vo20;	  
									  end if;
									  
									  state<= s1;
									  
                  when s1=>  Tinm<=Tin-Tim;   
						           Vonm<=Von-Vom;
                             Voim<=Vof-Vom;									  
									  state<= s2;
									  
						when s2=>    
                             TVd<= Tinm/Vonm; 
									  state<= s3;
						when s3=>			  
                             TVm<=TVd*Voim;
									  state<= s4;
						when s4=>			  
                             Ti<= resize(TVm+Tim-offset,7,-8);
                             state<= s5; 
									  if Tmin<=Ti and Ti<Tmax then fin<='1'; permiso:='1';
							        end if;   			  
                  when s5=>  if permiso='0' then                             
									  state<= s6;
									  else									  
									  state<= s5;
									  end if;
                             eTi<= Ti(7 downto 0);
					              dTi<= resize(Ti(-1 downto -8)*Ke,9,0);					              
					   when s6=>  
                             e<= to_slv(eTi);
					              d<= to_slv(dTi);
					              state<= si;				  
						
             end case;      
      			    
			   end if;

          end process;      
end Behavioral;