       //***********************************************************************
       // P1RCANSTS - PCR Closed/Cancelled/POP status label
       //***********************************************************************
     D P1RCANSTS       PR                  EXTPGM('P1RCANSTS')
     D  PrmItmnum                     8S 0 Const
     D  PrmJobnum7                    7S 0 Const
     D  PrmLabel                     15A
