// ------------------------------------------------------------------------------------------------
// Copyright 2022 by Heqing Huang (feipenghhq@gamil.com)
// Author: Heqing Huang
//
// Date Created: 07/10/2022
// ------------------------------------------------------------------------------------------------
// veriRISCV
// ------------------------------------------------------------------------------------------------
// cpu init code - config and setup peripherals
// ------------------------------------------------------------------------------------------------

void _init() {

    // init the uart with default configuration
    // TBD

    // write the trap handler register
    // TBD

    // enable global interrupt (mstatus)
    //_write_csr(mstatus, 0x8);
    // enable interrupt (mie)
    //_write_csr(mie, 0x888);

}