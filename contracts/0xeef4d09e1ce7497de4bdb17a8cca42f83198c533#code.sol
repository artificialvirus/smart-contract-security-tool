// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Techno Dreaming
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                                                                    //
//                                                                                                                                                                                                    //
//            ,----,                                                                                                                                                                                  //
//          ,/   .`|                                ,--,          ,--.     ,----..                                                                     ____                     ,--.                  //
//        ,`   .'  :     ,---,.   ,----..         ,--.'|        ,--.'|    /   /   \         ,---,     ,-.----.        ,---,.    ,---,                ,'  , `.    ,---,        ,--.'|   ,----..        //
//      ;    ;     /   ,'  .' |  /   /   \     ,--,  | :    ,--,:  : |   /   .     :      .'  .' `\   \    /  \     ,'  .' |   '  .' \            ,-+-,.' _ | ,`--.' |    ,--,:  : |  /   /   \       //
//    .'___,/    ,'  ,---.'   | |   :     : ,---.'|  : ' ,`--.'`|  ' :  .   /   ;.  \   ,---.'     \  ;   :    \  ,---.'   |  /  ;    '.       ,-+-. ;   , || |   :  : ,`--.'`|  ' : |   :     :      //
//    |    :     |   |   |   .' .   |  ;. / |   | : _' | |   :  :  | | .   ;   /  ` ;   |   |  .`\  | |   | .\ :  |   |   .' :  :       \     ,--.'|'   |  ;| :   |  ' |   :  :  | | .   |  ;. /      //
//    ;    |.';  ;   :   :  |-, .   ; /--`  :   : |.'  | :   |   \ | : ;   |  ; \ ; |   :   : |  '  | .   : |: |  :   :  |-, :  |   /\   \   |   |  ,', |  ': |   :  | :   |   \ | : .   ; /--`       //
//    `----'  |  |   :   |  ;/| ;   | ;     |   ' '  ; : |   : '  '; | |   :  | ; | '   |   ' '  ;  : |   |  \ :  :   |  ;/| |  :  ' ;.   :  |   | /  | |  || '   '  ; |   : '  '; | ;   | ;  __      //
//        '   :  ;   |   :   .' |   : |     '   |  .'. | '   ' ;.    ; .   |  ' ' ' :   '   | ;  .  | |   : .  /  |   :   .' |  |  ;/  \   \ '   | :  | :  |, |   |  | '   ' ;.    ; |   : |.' .'     //
//        |   |  '   |   |  |-, .   | '___  |   | :  | ' |   | | \   | '   ;  \; /  |   |   | :  |  ' ;   | |  \  |   |  |-, '  :  | \  \ ,' ;   . |  ; |--'  '   :  ; |   | | \   | .   | '_.' :     //
//        '   :  |   '   :  ;/| '   ; : .'| '   : |  : ; '   : |  ; .'  \   \  ',  /    '   : | /  ;  |   | ;\  \ '   :  ;/| |  |  '  '--'   |   : |  | ,     |   |  ' '   : |  ; .' '   ; : \  |     //
//        ;   |.'    |   |    \ '   | '/  : |   | '  ,/  |   | '`--'     ;   :    /     |   | '` ,/   :   ' | \.' |   |    \ |  :  :         |   : '  |/      '   :  | |   | '`--'   '   | '/  .'     //
//        '---'      |   :   .' |   :    /  ;   : ;--'   '   : |          \   \ .'      ;   :  .'     :   : :-'   |   :   .' |  | ,'         ;   | |`-'       ;   |.'  '   : |       |   :    /       //
//                   |   | ,'    \   \ .'   |   ,/       ;   |.'           `---`        |   ,.'       |   |.'     |   | ,'   `--''           |   ;/           '---'    ;   |.'        \   \ .'        //
//                   `----'       `---`     '---'        '---'                          '---'         `---'       `----'                     '---'                     '---'           `---`          //
//                                                                                                                                                                                                    //
//                                                                                                                                                                                                    //
//                                                                                                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract DREAM is ERC721Creator {
    constructor() ERC721Creator("Techno Dreaming", "DREAM") {}
}