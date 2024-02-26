// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// AutomationCompatible.sol imports the functions from both ./AutomationBase.sol and
// ./interfaces/AutomationCompatibleInterface.sol
import "lib/chainlink/v0.8/v0.8/automation/AutomationCompatible.sol";
import "../src/TokenBank.sol";
import "../src/MyERC20.sol";
/**
 * @dev Example contract, use the Forwarder as needed for additional security.
 *
 * @notice important to implement {AutomationCompatibleInterface}
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract Robot is AutomationCompatibleInterface {
    TokenBank private tokenBank;
    MyERC20 private myERC20;

    /**
     * Public counter variable
     */
    uint256 public counter;

    /**
     * Use an interval in seconds and a timestamp to slow execution of Upkeep
     */
    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    constructor(address _tokenBank,address _myERC20) {
        tokenBank = TokenBank(_tokenBank);
        myERC20 = MyERC20(_myERC20);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        if(myERC20.balanceOf(address(tokenBank)) > 10000){
            upkeepNeeded = true;
        }
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        tokenBank.withDraw();
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }
}
