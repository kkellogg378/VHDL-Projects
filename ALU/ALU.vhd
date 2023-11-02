-- RTL Model: Arithmetic Logic Unit
--
-- This device handles an input of an OPCODE (Operation code)
-- and a DIN (Data In) and supplies an ACCUM (Accumulator: 
-- Data Out) and a FLAGS (Status Flag output) in return. 
--
-- This device has a clock-independent active-high RESET,
-- a clock-dependent active-high ENABLE, and the generic BITS 
-- which defaults to 8.
-- 
-- Authors: David Shaw, Kyler Kellogg, Seth Glasscock
-- ECE 358 - Project 4
-----------------------------------------------------

   library IEEE;
   use     IEEE.std_logic_1164.all;
   use     IEEE.numeric_std.all;

-------------
entity ALU is
-------------
  generic ( BITS   : natural := 8 );                                           -- ALU bit width
  port    ( RESET  : in  std_logic;                                            -- Active high master reset
            CLOCK  : in  std_logic;                                            -- Master clock
            ENABLE : in  std_logic;                                            -- Clock enable
            OPCODE : in  std_logic_vector (3 downto 0);                        -- ALU operation
            DIN    : in  std_logic_vector (BITS-1 downto 0);                   -- Data input
            ACCUM  : out std_logic_vector (BITS-1 downto 0);                   -- Accumulator output
            FLAGS  : out std_logic_vector (3 downto 0));                       -- Status flags output (NVCZ)
end ALU;

--------------------------
architecture RTL of ALU is 
--------------------------

  signal INSTRUCTION     : natural range 0 to 15;                              --
  
  type   OPERATION_ARRAY is array (15 downto 0) of unsigned (BITS downto 0);   --
  signal OPERATION       : OPERATION_ARRAY;                                    --
  
  signal RESULT          : unsigned (BITS downto 0);                           --
  
  signal A               : unsigned (BITS-1 downto 0);                         --
  signal B               : unsigned (BITS-1 downto 0);                         --
  
  signal CARRY           : natural range 0 to 1;                               --
  
  signal NFLAG           : std_logic;                                          --
  signal VFLAG           : std_logic;                                          --
  signal CFLAG           : std_logic;                                          --
  signal ZFLAG           : std_logic;                                          --
  
  signal ZERO            : std_logic;                                          --
  signal OVERFLOW        : std_logic;                                          --
  
begin 
  
  OPERATION (0)  <= resize (A, BITS+1) + resize (B, BITS+1) + CARRY;           -- ADD       A=A+B+C 
  OPERATION (1)  <= resize (A, BITS+1) + resize (not B, BITS+1) + CARRY;           -- SUB       A=A-B+C 
  OPERATION (2)  <= resize (A, BITS+1) + 1;                                    -- INCREMENT A=A+1 
  OPERATION (3)  <= resize (A, BITS+1) - 1;                                    -- DECREMENT A=A-1 
  OPERATION (4)  <= resize (A, BITS+1) + resize (not B, BITS+1) + 1;                   -- COMPARE   A-B 
  OPERATION (5)  <= A (BITS-1 downto 0) & CFLAG;                               -- Shift left 
  OPERATION (6)  <= A (0) & CFLAG & A (BITS-1 downto 1);                       -- Shift right 
  --OPERATION (7)  <= CFLAG & A (BITS-1 downto 1) & NFLAG;                       -- ASR 
  OPERATION (7)  <= A (0) & A(BITS-1) & A (BITS-1 downto 1);                   -- ASR
  OPERATION (8)  <= resize (A, BITS+1) or resize (B, BITS+1);                  -- uses OR symbol 
  OPERATION (9)  <= resize (A, BITS+1) and resize (B, BITS+1);                 -- uses AND symbol 
  OPERATION (10) <= resize (A, BITS+1) xor resize (B, BITS+1);                 -- uses the xor logic symbol 
  OPERATION (11) <= resize (not A, BITS+1);                                    -- uses the not logic symbol 
  OPERATION (12) <= resize (unsigned (DIN), BITS+1);                                      -- A is equal to DIN 
  OPERATION (13) <= resize (unsigned (DIN), BITS+1);                                      -- B is equal to DIN 
  OPERATION (14) <= (BITS => '0', others => '0');                              -- C is equal to 0 
  OPERATION (15) <= (BITS => '1', others => '0');                              -- C is equal to 1 
  
  INSTRUCTION    <= To_Integer (unsigned (OPCODE));
  RESULT         <= OPERATION (INSTRUCTION);
  
  ----------------------------------------------
  REGISTER_PROCESS: process (RESET, CLOCK) begin
  ----------------------------------------------
    if (RESET = '1') then
      A      <= (others => '0');
      B      <= (others => '0');
    elsif (CLOCK'event and CLOCK = '1') then
      if (ENABLE = '1') then
        case INSTRUCTION is                                
          when 4      => null;                             
          when 13     => B <= RESULT (BITS-1 downto 0);    
          when 14     => null;                             
          when 15     => null;                             
          when others => A <= RESULT (BITS-1 downto 0);    
        end case;                                          
      end if;
    end if;
  end process REGISTER_PROCESS;
  
  ------------------------------------------
  FLAG_PROCESS: process (RESET, CLOCK) begin       
  ------------------------------------------
    if (RESET = '1') then
      NFLAG <= '0';
      VFLAG <= '0';
      CFLAG <= '0';
      ZFLAG <= '0';
    elsif (CLOCK'event and CLOCK = '1') then
      if (ENABLE = '1') then
        case INSTRUCTION is                                
          when 0  => NFLAG <= RESULT (BITS-1);                                     --
                     VFLAG <= OVERFLOW;                    
                     CFLAG <= RESULT (BITS);               
                     ZFLAG <= ZERO;                        
          when 1  => NFLAG <= RESULT (BITS-1); 
                     VFLAG <= OVERFLOW;
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 2  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 3  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 4  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 5  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 6  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 7  => NFLAG <= RESULT (BITS-1);
                     CFLAG <= RESULT (BITS);
                     ZFLAG <= ZERO;
          when 8  => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 9  => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 10 => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 11 => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 12 => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 13 => NFLAG <= RESULT (BITS-1);
                     ZFLAG <= ZERO;
          when 14 => CFLAG <= RESULT (BITS);
          when 15 => CFLAG <= RESULT (BITS);
        end case;
      end if;
    end if;
  end process FLAG_PROCESS;
  
  ACCUM    <= std_logic_vector (A);                                            -- Converts A to unsigned and drives ACCUM
  FLAGS    <= NFLAG & VFLAG & CFLAG & ZFLAG;                                   -- Drives FLAGS with flag signals in NVCZ order
  
  CARRY    <= 0 when (CFLAG = '0') else 1;                                     -- CARRY is CFLAG but natural
  
  OVERFLOW <=     RESULT (BITS-1) when (A (BITS-1) = '0' and B (BITS-1) = '0' and INSTRUCTION = 0) 
         else not RESULT (BITS-1) when (A (BITS-1) = '1' and B (BITS-1) = '1' and INSTRUCTION = 0) 
         else     RESULT (BITS-1) when (A (BITS-1) = '0' and B (BITS-1) = '1' and INSTRUCTION = 1) 
         else not RESULT (BITS-1) when (A (BITS-1) = '1' and B (BITS-1) = '0' and INSTRUCTION = 1) 
         else '0';
  ZERO     <= '1' when RESULT (BITS-1 downto 0) = 0 else '0';                                         -- Checks whether A = 0 and updates ZFLAG accordingly
  
end architecture RTL;