pragma solidity ^0.6.7;

import "./libs/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "./libs/Ownable.sol";
import "./libs/UniversalERC20.sol";

contract SwapXProxy is Ownable {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;

    address public swapXImpl;
    bool public paused;

    event Swapped(
        address indexed sender,
        IERC20 indexed srcToken,
        IERC20 indexed dstToken,
        address dstReceiver,
        uint256 amount,
        uint256 spentAmount,
        uint256 returnAmount,
        uint256 minReturnAmount,
        address referrer
    );

    event ImplementationUpdated(address indexed newImpl);
    event Paused(address account);
    event Unpaused(address account);

    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }


    constructor(address impl) public {
        setNewImpl(impl);
        paused = false;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }

    receive() external payable {
        require(msg.sender != tx.origin, "SwapX: do not send BNB directly");
    }

    function setNewImpl(address impl) public onlyOwner {
        swapXImpl = impl;
        emit ImplementationUpdated(address(impl));
    }

    function swap(
        IERC20 srcToken,
        IERC20 dstToken,
        address dstReceiver,
        uint256 amount,
        uint256 minReturnAmount,
        address referrer,
        bytes calldata data
    ) 
        external 
        payable 
        whenNotPaused
        returns (uint256 returnAmount)
    {
        require(minReturnAmount > 0, "Min return should not be 0");
        require(data.length > 0, "Call data should exist");

        dstReceiver = (dstReceiver == address(0)) ? msg.sender : dstReceiver;
        uint256 initialSrcBalance = srcToken.universalBalanceOf(msg.sender);
        uint256 initialDstBalance = dstToken.universalBalanceOf(dstReceiver);

        {
        (bool success, bytes memory returndata) = swapXImpl.call{value: msg.value}(data);
        if (!success)  {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("swap failed");
            }
        }
        }

        uint256 spentAmount = initialSrcBalance.sub(srcToken.universalBalanceOf(msg.sender));
        returnAmount = dstToken.universalBalanceOf(dstReceiver).sub(initialDstBalance);
        require(returnAmount >= minReturnAmount, "Return amount is not enough");
        
        emit Swapped(
            msg.sender,
            srcToken,
            dstToken,
            dstReceiver,
            amount,
            spentAmount,
            returnAmount,
            minReturnAmount,
            referrer
        );
    }

    function rescueFund(IERC20 asset, uint256 amount) public onlyOwner {
        asset.universalTransfer(msg.sender, amount);
    }
}