// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title: Mature & Nature
/// @author: manifold.xyz

import "./manifold/ERC721Creator.sol";

///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//                                                                                   //
//                  _                     ___         __      _                      //
//      /\/\   __ _| |_ _   _ _ __ ___   ( _ )     /\ \ \__ _| |_ _   _ _ __ ___     //
//     /    \ / _` | __| | | | '__/ _ \  / _ \/\  /  \/ / _` | __| | | | '__/ _ \    //
//    / /\/\ | (_| | |_| |_| | | |  __/ | (_>  < / /\  | (_| | |_| |_| | | |  __/    //
//    \/    \/\__,_|\__|\__,_|_|  \___|  \___/\/ \_\ \/ \__,_|\__|\__,_|_|  \___|    //
//                                                                                   //
//                                                                                   //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////


contract MN is ERC721Creator {
    constructor() ERC721Creator("Mature & Nature", "MN") {}
}