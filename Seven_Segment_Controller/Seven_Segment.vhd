-----------------------------------------------------------------------------------------
-- Project 3: Seven_Segment 
-- Kyler Kellogg, Seth Glasscock, David Shaw
-- 10/02/2023
-----------------------------------------------------------------------------------------
-- This circuit controls a series of 7-segment displays with decimal points for each digit.
-- The default number of digits that this board can handle is 8, but that number is a 
-- constant that is easily changed.
-- 
-- The inputs include a clock-independent RESET, active high, a CLOCK and ENABLE input, a
-- synchronous CLEAR, a BLANKING control, a DATA input, and a DP input.
-- 
-- The BLANKING control will cause the output to have leading zeroes when it is LOW, and
-- will cause the output to not display leading zeroes when it is HIGH.
-- 
-- The DATA input stores the number to be displayed.
-- 
-- The DP input is a decimal point enable. It will store the location of the decimal.
-- 
-- The outputs include a DIGIT, which is an enabler for the 7-segment digits, and a SEGMENT,
-- which is an enabler for the segments in the selected 7-segment display.
-- 
-----------------------------------------------------------------------------------------
   library IEEE;
   use     IEEE.std_logic_1164.all;
   use     IEEE.numeric_std.all;

-----------------------
entity SEVEN_SEGMENT is
-----------------------
   generic ( DIGITS   : natural := 8 );                                -- The number of digits in the display
   port    ( RESET    : in  std_logic;                                 -- Active high master reset
             CLOCK    : in  std_logic;                                 -- Master clock
             ENABLE   : in  std_logic;                                 -- Clock enable
             CLEAR    : in  std_logic;                                 -- Synchronous clear
             BLANKING : in  std_logic;                                 -- Leading 0 blanking control
             DATA     : in  std_logic_vector (4*DIGITS-1 downto 0);    -- Display value
             DP       : in  std_logic_vector   (DIGITS-1 downto 0);    -- Decimal point enable for each digit
             DIGIT    : out std_logic_vector   (DIGITS-1 downto 0);    -- 7-segment digit enable
             SEGMENT  : out std_logic_vector          (7 downto 0));   -- 7-segment segment enable
end SEVEN_SEGMENT;

----------------------------------
architecture RTL of Seven_Segment is
----------------------------------

  signal COUNT        : natural range 0 to DIGITS - 1;                 -- Count signal is used to select which of the 4 bit hex digits in DATA drives SEGMENT
  signal BLANK_VECTOR : std_logic_vector (DIGITS downto 0);            -- Blank_Vector controls the blanking of each digit
                      

  function To_Segment (DATA : std_logic_vector (3 downto 0)) return std_logic_vector is begin
    case DATA is
      when "0000" => return "0111111";                                 -- "0"
      when "0001" => return "0000110";                                 -- "1"
	  when "0010" => return "1011011";                                 -- "2"
	  when "0011" => return "1001111";                                 -- "3"
	  when "0100" => return "1100110";                                 -- "4"
	  when "0101" => return "1101101";                                 -- "5"
	  when "0110" => return "1111101";                                 -- "6"
	  when "0111" => return "0000111";                                 -- "7"
	  when "1000" => return "1111111";                                 -- "8"
	  when "1001" => return "1101111";                                 -- "9"
	  when "1010" => return "1110111";                                 -- "A"
	  when "1011" => return "1111100";                                 -- "B"
	  when "1100" => return "0111001";                                 -- "C"
      when "1101" => return "1011110";                                 -- "D"
      when "1110" => return "1111001";                                 -- "E"
      when "1111" => return "1110001";                                 -- "F"
      when others => return "1000000";                                 -- Use a "dash" character for an unknown value
    end case;
  end To_Segment;

begin
  --------------------------------------------
  COUNT_PROCESS: process (RESET, CLOCK) begin
  --------------------------------------------
    if (RESET = '1') then                                              -- if RESET
    elsif (CLOCK'event and CLOCK = '1') then                           -- if ENABLE and CLOCK rising edge                                        
      if (CLEAR = '1') then                                            -- if CLEAR = '1' then                                               
        COUNT <= 0;                                                    -- Sets COUNT to 0                                   
      elsif (ENABLE = '1') then                                        -- else if ENABLE = '1' then                                        
        if (COUNT = DIGITS - 1)then                                    --                                           
          COUNT <= 0;                                                  -- then set COUNT to 0                                        
        else COUNT <= COUNT + 1;                                       -- else increment COUNT
        end if;                                                       
      end if;	                                                     
    end if;
  end process;

  --------------------------------------------
  OUTPUT_PROCESS: process (RESET, CLOCK) begin
  --------------------------------------------
    if (RESET = '1') then                                              -- Reset: Initialize DIGIT and SEGMENT
      DIGIT <= (others => '0');                                        
      SEGMENT <= "00000000";                                           -- All segments off initially
    elsif (CLOCK'event and CLOCK = '1') then                           -- On rising clock edge:
      if (CLEAR = '1') then                                            
        DIGIT <= (others => '0');                                      -- Clear: Set DIGIT and SEGMENT to '0's
        SEGMENT <= "00000000";                                         -- All segments off
      elsif (ENABLE = '1') then
        ---------------------------
        for I in 0 to DIGITS-1 loop                                    -- Run for each digit
        ---------------------------
          if (I = COUNT) then
            DIGIT(I)  <= '1';                                          -- Set DIGIT(I) to '1' for the active digit
            if (BLANK_VECTOR (I) = '1') then
              SEGMENT <= DP(I) & "0000000";                            -- Leading zero blanking: Display '0' as blank
            else
              SEGMENT <= DP(I) & To_Segment(DATA(4*I+3 downto 4*I));   -- Display the appropriate segment pattern for the digit
            end if;
          else
            DIGIT(I)  <= '0';                                          -- Deactivate other digits
          end if;
		---------------------------
        end loop;
		---------------------------
      end if;
    end if;
  end process OUTPUT_PROCESS;

  BLANK_VECTOR (DIGITS) <= BLANKING;                                   -- Set to '1' to turn on blanking or '0' to disable
  ------------------------------------------
  FORLOOP: for I in 1 to DIGITS - 1 generate
  ------------------------------------------
    BLANK_VECTOR (I)    <= BLANK_VECTOR (I + 1) when (DATA (4*I+3 downto 4*I) = "0000") else '0';
  ------------------------------------------
  end generate FORLOOP;
  ------------------------------------------
  BLANK_VECTOR (0)      <= '0';                                        -- Digit 0 is always on

end architecture RTL;
