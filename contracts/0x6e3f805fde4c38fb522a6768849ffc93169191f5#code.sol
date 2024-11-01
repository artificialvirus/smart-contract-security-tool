// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: gug-collab
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

//////////////////////////////////////////////////////////////
//                                                          //
//                                                          //
//    @@@@@@@@@@@#####*@@@@@@@@#############@####@@@@@@@    //
//    @@@@@@@@@@@@######@@@@@@@#########@####@####@@@@@@    //
//    @@@@@@@@@@@#+=-+##@@@@@@@###############+-##@@@@@@    //
//    @@@@@@@@@@@#+::-##@@@@@@@########@####@#+.##@@@@@@    //
//    @@@@@@@@@@@#=..-##@@@@@@####@###@####@@#+.##@@@@@@    //
//    @@@@@@@####=-..-##@@@@@@####@###@######=-.==##@@@@    //
//    @@@@@@@####....-##@@@@@@########@###@##....:##@@@@    //
//    @@@@@@@##-.....-##@@@@@@@############+-....:##@@@@    //
//    @@@@@@##+:.....-##@@@@@@@@@####@####+=:....:##@@@@    //
//    @@@@@@##.......-##@@@@@@@@@@@#######.......:##@@@@    //
//    @@@@##-:........:#################=:........:*#@@@    //
//    @@@@##:..........*****************-..........*#@@@    //
//    @@@@##:......................................*#@@@    //
//    @@@#*-.......................................:-##@    //
//    @@@#*..........................................##@    //
//    @@@#*.......=****:..............:****-.........##@    //
//    @##=-.......=#***::.............:###*=.........##@    //
//    @##.........=####::.............:####=.........##@    //
//    @##........*## :#::............+*#: #=..........+#    //
//    @##......::*## :#::............*##: #=..........+#    //
//    @##......:-### :#:.............*##: #=..........+#    //
//    @##......+##= ###:.............** +##=.........##%    //
//    #**......+##- ###:.............**.+##=.........##@    //
//    #+.......=+#- ###:.............**+*##=.........##@    //
//    #+.......::##*#+-..............+*###::.........##@    //
//    #+:........###*+:..............+*###...........##@    //
//    @##.........:::::..............................##@    //
//    @##..........................................=+##@    //
//    @##..........................................*#@@@    //
//    @##........................................:##@@@@    //
//    @##=-...................................:===##@@@@    //
//    @@@#*...................................-###@@@@@@    //
//    @@@#########=..................*#########@@@@@@@@@    //
//    @@@#########+-.........:-------*#########@@@@@@@@@    //
//    @@@@@@@@@@@@##.........+########@@@@@@@@@@@@@@@@@@    //
//    @@@@@@@@@@@@###################%@@@@@@@@@@@@@@@@@@    //
//                                                          //
//    ╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋┏┓                              //
//    ╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋╋┃┃  stay psychedelic            //
//    ┏━━┳┓┏┳━┳┓┏┳━━┳┓┏┳━┳┓┏┫┗━┳┓╋┏┳━━┳━┓┏━━┓               //
//    ┃┏┓┃┃┃┃┏┫┃┃┃┏┓┃┃┃┃┏┫┃┃┃┏┓┃┃╋┃┃┃━┫┏┓┫┏┓┃               //
//    ┃┗┛┃┗┛┃┃┃┗┛┃┗┛┃┗┛┃┃┃┗┛┃┃┃┃┗━┛┃┃━┫┃┃┃┏┓┃               //
//    ┗━┓┣━━┻┛┗━━┻━┓┣━━┻┛┗━━┻┛┗┻━┓┏┻━━┻┛┗┻┛┗┛               //
//    ┏━┛┃╋╋╋╋╋╋╋┏━┛┃╋╋╋╋╋╋╋╋╋╋┏━┛┃                         //
//    ┗━━┛╋╋╋╋╋╋╋┗━━┛╋╋╋╋╋╋╋╋╋╋┗━━┛                         //
//                                                          //
//                                                          //
//////////////////////////////////////////////////////////////


contract GUGC is ERC721Creator {
    constructor() ERC721Creator("gug-collab", "GUGC") {}
}