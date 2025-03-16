// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @chainlink/contracts/src/v0.8/AutomationBase.sol


pragma solidity ^0.8.0;

contract AutomationBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol


pragma solidity ^0.8.0;

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/AutomationCompatible.sol


pragma solidity ^0.8.0;



abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}

// File: @chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol


pragma solidity ^0.8.4;

// End consumer library.
library VRFV2PlusClient {
  // extraArgs will evolve to support new features
  bytes4 public constant EXTRA_ARGS_V1_TAG = bytes4(keccak256("VRF ExtraArgsV1"));
  struct ExtraArgsV1 {
    bool nativePayment;
  }

  struct RandomWordsRequest {
    bytes32 keyHash;
    uint256 subId;
    uint16 requestConfirmations;
    uint32 callbackGasLimit;
    uint32 numWords;
    bytes extraArgs;
  }

  function _argsToBytes(ExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EXTRA_ARGS_V1_TAG, extraArgs);
  }
}

// File: @chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFSubscriptionV2Plus.sol


pragma solidity ^0.8.0;

/// @notice The IVRFSubscriptionV2Plus interface defines the subscription
/// @notice related methods implemented by the V2Plus coordinator.
interface IVRFSubscriptionV2Plus {
  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint256 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint256 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint256 subId, address to) external;

  /**
   * @notice Accept subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint256 subId) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint256 subId, address newOwner) external;

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription with LINK, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   * @dev Note to fund the subscription with Native, use fundSubscriptionWithNative. Be sure
   * @dev  to send Native with the call, for example:
   * @dev COORDINATOR.fundSubscriptionWithNative{value: amount}(subId);
   */
  function createSubscription() external returns (uint256 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return nativeBalance - native balance of the subscription in wei.
   * @return reqCount - Requests count of subscription.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(
    uint256 subId
  )
    external
    view
    returns (uint96 balance, uint96 nativeBalance, uint64 reqCount, address owner, address[] memory consumers);

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint256 subId) external view returns (bool);

  /**
   * @notice Paginate through all active VRF subscriptions.
   * @param startIndex index of the subscription to start from
   * @param maxCount maximum number of subscriptions to return, 0 to return all
   * @dev the order of IDs in the list is **not guaranteed**, therefore, if making successive calls, one
   * @dev should consider keeping the blockheight constant to ensure a holistic picture of the contract state
   */
  function getActiveSubscriptionIds(uint256 startIndex, uint256 maxCount) external view returns (uint256[] memory);

  /**
   * @notice Fund a subscription with native.
   * @param subId - ID of the subscription
   * @notice This method expects msg.value to be greater than or equal to 0.
   */
  function fundSubscriptionWithNative(uint256 subId) external payable;
}

// File: @chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol


pragma solidity ^0.8.0;



// Interface that enables consumers of VRFCoordinatorV2Plus to be future-proof for upgrades
// This interface is supported by subsequent versions of VRFCoordinatorV2Plus
interface IVRFCoordinatorV2Plus is IVRFSubscriptionV2Plus {
  /**
   * @notice Request a set of random words.
   * @param req - a struct containing following fields for randomness request:
   * keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * requestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * extraArgs - abi-encoded extra args
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(VRFV2PlusClient.RandomWordsRequest calldata req) external returns (uint256 requestId);
}

// File: @chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFMigratableConsumerV2Plus.sol


pragma solidity ^0.8.0;

/// @notice The IVRFMigratableConsumerV2Plus interface defines the
/// @notice method required to be implemented by all V2Plus consumers.
/// @dev This interface is designed to be used in VRFConsumerBaseV2Plus.
interface IVRFMigratableConsumerV2Plus {
  event CoordinatorSet(address vrfCoordinator);

  /// @notice Sets the VRF Coordinator address
  /// @notice This method should only be callable by the coordinator or contract owner
  function setCoordinator(address vrfCoordinator) external;
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/IOwnable.sol


pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}

// File: @chainlink/contracts/src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol


pragma solidity ^0.8.0;


/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line gas-custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line gas-custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol


pragma solidity ^0.8.0;


/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: @chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol


pragma solidity ^0.8.4;




/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinatorV2Plus.
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBaseV2Plus, and can
 * @dev initialize VRFConsumerBaseV2Plus's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumerV2Plus is VRFConsumerBaseV2Plus {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _subOwner)
 * @dev       VRFConsumerBaseV2Plus(_vrfCoordinator, _subOwner) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create a subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords, extraArgs),
 * @dev see (IVRFCoordinatorV2Plus for a description of the arguments).
 *
 * @dev Once the VRFCoordinatorV2Plus has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBaseV2Plus.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2Plus is IVRFMigratableConsumerV2Plus, ConfirmedOwner {
  error OnlyCoordinatorCanFulfill(address have, address want);
  error OnlyOwnerOrCoordinator(address have, address owner, address coordinator);
  error ZeroAddress();

  // s_vrfCoordinator should be used by consumers to make requests to vrfCoordinator
  // so that coordinator reference is updated after migration
  IVRFCoordinatorV2Plus public s_vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) ConfirmedOwner(msg.sender) {
    if (_vrfCoordinator == address(0)) {
      revert ZeroAddress();
    }
    s_vrfCoordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2Plus expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) external {
    if (msg.sender != address(s_vrfCoordinator)) {
      revert OnlyCoordinatorCanFulfill(msg.sender, address(s_vrfCoordinator));
    }
    fulfillRandomWords(requestId, randomWords);
  }

  /**
   * @inheritdoc IVRFMigratableConsumerV2Plus
   */
  function setCoordinator(address _vrfCoordinator) external override onlyOwnerOrCoordinator {
    if (_vrfCoordinator == address(0)) {
      revert ZeroAddress();
    }
    s_vrfCoordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);

    emit CoordinatorSet(_vrfCoordinator);
  }

  modifier onlyOwnerOrCoordinator() {
    if (msg.sender != owner() && msg.sender != address(s_vrfCoordinator)) {
      revert OnlyOwnerOrCoordinator(msg.sender, owner(), address(s_vrfCoordinator));
    }
    _;
  }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: FGToken.sol


pragma solidity ^0.8.23;




contract FGToken is ERC20 {

    address owner;
    address approvedcontract;

    constructor() ERC20("FeelG Participation Token","FGT"){
        owner=msg.sender;
    }

    function setApprovedcontract(address _approvedcontract)
    external onlyowner{
        approvedcontract = _approvedcontract;
    }

    function mint(address _to, uint _numberoftokens) external {
        require(msg.sender == approvedcontract, "Contract not approved");
        _mint(_to, _numberoftokens);
    }

    modifier onlyowner() {
        require(msg.sender == owner, "Not a creator of FG");
        _;
    }


}
// File: CosmoonautsDRGV1.1.sol


pragma solidity ^0.8.23;

// Loading OpenZeppelin's shields to defend against reentrant function call invaders


// Loading Chainlink's star maps and interfaces for interstellar randomness and automation
//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";





// Loading the blueprint of the FeelG token, our intergalactic currency


// Initializing our main spacecraft, which is powered by Chainlink's VRF thrusters, OpenZeppelin's reentrancy shields,
// and Chainlink's AutomationCompatible Interface guidance systems
contract CosmoonautsDGR_v1 is VRFConsumerBaseV2Plus , ReentrancyGuard, AutomationCompatibleInterface {
    //VRFCoordinatorV2Interface COORDINATEUR;

// Key Wallets :

    address payable company = payable(0x4aDc10046605177025Cf7fcF09eff45D1E3cA956);
    address payable fondateurF = payable(0xdF82C0440c409759D5B5b6937B2c70B716Db6fb2);
    address payable fondateurEE = payable(0x1c11f38FE2EF94398C388CC5f4EF4D23A991abA4);
    address payable fondateurL = payable(0x92D046ffB05aCA324bD33A86c61c4F859A6D587e);
    address payable fondateurG = payable(0x5820A3391340E73fd4529ad0313094d49da6C89E);

    address payable LinkAutomation = payable(0x231a24632918533bAe904fD23c87930cAf1FdEE5);

//VRF
    // Setting up our Chainlink's Verifiable Random Function (VRF) for interstellar navigation
    uint256 private abonnementId;
    bytes32 private hashCle;
    address private coordonnateurVRF;
    uint32 limiteGazRappel = 2500000;
    uint16 confirmationsRequises = 3;

    // An array of cosmic numbers generated by the VRF, like celestial coordinates
    uint256[] public listeNombresAleatoires;
    // The number of celestial words requested from the VRF for our star chart
    uint256 public nombreMotsDemandes;
    // The number of celestial word batch requests still being deciphered by the VRF's supercomputers
    uint256 public requetesRestantes;

    // A star map to track which celestial word requests have been fully deciphered
    mapping(uint256 => bool) public requetesTraitees;

//UPKEEP
    // These Boolean flags are used by our ground control (Chainlink Upkeep) to check two important events. 
    // The first, randomNumberGenerated, signals when our map to the stars (random numbers) is ready. 
    // The second, allParticipantsRegistered, lets us know when all our brave Cosmoonauts are onboard and ready for take-off.
    bool public randomNumberGenerated = false;
    bool public allParticipantsRegistered = false;

//Game Initialisation

    // This boolean is our main switch. If the game is active, then our launchpad is open for business!
    bool public isGameActive;

    // A helpful beacon for our front-end team. This event will signal the current status of our game. 
    // If the launchpad is open, then it's time to board the rocket!
    event GameToggled(bool launchingclosed);
    // When all Cosmoonauts are aboard, this event is emitted and the launchpad doors close. Hold on tight, it's almost blast off time!
    event LaunchpadClosed();

    // This boolean checks if we're in mid-flight or if we're waiting on the ground. We wouldn't want to leave without all our passengers, would we?
    bool public launchingclosed;

    // This isn't just a token, it's a badge of honor and the mark of an OG! Our brave Cosmoonauts receive FeelG Tokens (FGT) as a token of gratitude 
    // for being amongst the first to embark on this incredible journey. These tokens are proof of their bravery, their commitment to the cause, 
    // and a promise of future surprises for our original explorers. To add FeelG Tokens to your wallet, use the following details:
    // Contract Address: <enter contract address here>
    // Token Symbol: FGT
    FGToken FGT;

    // This isn't the work of one person, but a team of four curious crypto enthusiasts and NFT holders who believe in the power of technology 
    // and the promise of a decentralized future. We are FeelG, pioneers of the Decentralized Autonomous Lottery, striving to abolish boundaries 
    // and send people to the moon. Here's to the fearless leaders of our Space Odyssey!
    address payable Owner;

    // This struct keeps track of all the details of our missions. Each launch has a unique number, a list of brave Cosmoonauts, and the celestial 
    // riches they've won. The 'EntreeUtilisee' field keeps track of the cosmic coordinates used to select the winners. In the vastness of space, 
    // there's always a chance of landing on a planet that's already occupied. In such cases, our Cosmoonauts just set up their base on the nearest 
    // available spot.
    struct Launch {
        uint256 launchNumber;
        address[] participants;
        uint256[] prizes;
        uint256[] EntreeUtilisee;
        uint256[] numerosAleatoiresOrigine;
    }

    // This variable is our very own Cosmos' logbook. It chronicles the history of our intrepid voyages, recording the brave Cosmoonauts, their launches, 
    // and all the cosmic riches they've discovered on their journeys. This record of interstellar exploration serves as a testament to their boldness and the 
    // thrill of venturing into the unknown.
    Launch[] public launches;



    // Our alert system keeps everyone informed! This event broadcasts when a new Cosmoonaut has strapped in and is ready for launch.
    // It even tells us how many tokens they've been awarded for their bravery!
    event ParticipantRegistered(
        address indexed participant,
        uint256 tokensReceived
    );

    // Sound the alarms! This event signals that a new launch is underway.
    // The tension is palpable as we prepare to blast another group of adventurers into the cosmos.
    event LaunchStarted();

    // Our space mission doesn't run on hopes and dreams alone. We've got some strict parameters to follow.
    // This struct outlines the mission details, from the number of winners to the prize distribution and the time we have to get everyone on board.
    struct Parameters {
        uint256 threshold; // The maximum number of Cosmoonauts allowed on a single mission.
        uint256 mainprize; // The biggest prize a lucky Cosmoonaut can discover on their journey.
        uint256 numberwinner2; // The number of second-tier prizes available on this mission.
        uint256 prize2; // The size of the second-tier prize.
        uint256 numberwinner3; // The number of third-tier prizes available on this mission.
        uint256 prize3; // The size of the third-tier prize.
        uint256 numberwinner4; // The number of fourth-tier prizes available on this mission.
        uint256 prize4; // The size of the fourth-tier prize.
    }

    // Here we store our mission parameters, including the rules and prizes for each launch.
    // these don't change once a mission has begun.
    Parameters[] public parameters;

//Constructor
    // This constructor function is the control room of our launchpad, setting up everything needed for takeoff.
    // It links up with the VRF for fair draw results, connects to the FeelG Token (FGT), and appoints mission control (the contract's owner).
    constructor(
        uint256 _idAbonnement,
        bytes32 _hashCle,
        address _coordonnateurVRF,
        FGToken _FGT
    ) VRFConsumerBaseV2Plus(_coordonnateurVRF) {
        abonnementId = _idAbonnement;
        hashCle = _hashCle;
        coordonnateurVRF = _coordonnateurVRF;
        
        FGT = _FGT;
        Owner = payable(msg.sender);

        // Setting the stage for our interstellar journey.
        // Here we establish the ground rules for all of our future launches.
        initializeParam();

        // Setting the stage for our first mission.
        // We're adding an empty launch entry to our historical registry of launches, paving the way for many successful journeys to come.
        launches.push();
    }



    // This function, called only once by the constructor, establishes the ground rules for our space adventure.
    // These parameters set the crew size to 108, the grand prize to 100 MATIC, 
    // 5 secondary prizes of 10 MATIC each, 10 tertiary prizes of 5 MATIC each, 20 fourth prizes of 2.75 MATIC.
    function initializeParam() private {
        parameters.push(Parameters(108, 100000000000000000000 , 5, 10000000000000000000, 10, 5000000000000000000, 20, 2750000000000000000));
    }

//Random numbers GENERATION
//VRF Rocket Science Section


    // To send our Cosmoonauts on their journey, we need some galactic coordinates (random numbers). Here we request these coordinates from the Verifiable Random Function (VRF).
    // More participants mean a wider search for hospitable planets, hence more coordinates required!
    function demanderNombresAleatoires(uint256 nbMots) internal {
        require(nbMots > 0, "Le nombre de mots demandes doit etre superieur a 0.");
        nombreMotsDemandes = nbMots;

        // Now, since our VRF provides a maximum of 100 coordinates (random numbers) per request, 
        // we need to calculate how many requests to send based on the number of participants we have.
        uint256 nombreRequetes = (nbMots + 99) / 100;
        requetesRestantes = nombreRequetes;

        // Let's send the coordinate requests to our trusty VRF.
        for (uint256 i = 0; i < nombreRequetes; i++) {
            // If we have less than 100 coordinates remaining, we'll adjust the request to avoid getting too many.
            uint32 motsDansRequete = uint32(i < nombreRequetes - 1 ? 100 : nbMots % 100);

            // We're finally requesting the coordinates. Fingers crossed for some lucrative planets!
            uint256 requestId = s_vrfCoordinator.requestRandomWords(
                VRFV2PlusClient.RandomWordsRequest({
                keyHash: hashCle,
                subId: abonnementId,
                requestConfirmations: confirmationsRequises,
                callbackGasLimit: limiteGazRappel,
                numWords: motsDansRequete,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
                })
            );
            // We'll keep track of which requests have been processed and which are still pending.
            requetesTraitees[requestId] = false;
        }
    }

    // The VRF sends back our requested coordinates (random numbers) in batches. 
    // This function processes each batch as it arrives.
    function fulfillRandomWords(uint256 requestId, uint256[] calldata motsAleatoires)
        internal
        override
    {
        require(!requetesTraitees[requestId], "La requete a deja ete traitee.");

        // Each number in the array is a fresh, new coordinate for our Cosmoonauts!
        for (uint i = 0; i < motsAleatoires.length; i++) {
            
            listeNombresAleatoires.push(motsAleatoires[i]);

        }
        // We've processed this batch, so let's not repeat it.
        requetesTraitees[requestId] = true;
        requetesRestantes--;

        // When all the requests have been processed and we've got all our random numbers, we're ready to roll.
        if (requetesRestantes == 0) {
            // An event to signal our ground control (aka the front end) that all the coordinates for the mission have been generated.
            emit TousLesNombresAleatoiresGeneres();
            randomNumberGenerated = true; // The random number generation is finished. The stars are now aligned for the launch!
        }
    }

    event TousLesNombresAleatoiresGeneres();

    // In case of a successful launch, we need to clear our slate (aka list of random numbers) for the next mission.
    function effacerNombresAleatoires() internal {
        delete listeNombresAleatoires;
    }

//Launchpad Operations Section

    // Ignition sequence start! The function to begin the game.
    // Once the countdown begins, there's no turning back! This function fires up the engines and initiates the automatic launch sequence.
    function startGame() external onlyFGCreator {
        require(
            !isGameActive,
            "Attention Cosmoonauts, we're already in launch sequence. Grab your seats quickly!"
        );
        isGameActive = true; // The game is now live, and the rocket is boarding. It's all systems go from here!
    }

    // Sometimes, we encounter minor technical issues and we have to pause the launch sequence. This function handles that.
    function pauseGame() external onlyFGCreator {
        require(isGameActive, "Cosmoonauts, we're experiencing some minor technical difficulties. Standby for updates...");
        isGameActive = false;
    }

    // The function for Cosmoonauts to book their seats on our rocket. X is the number of seats they wish to book.
    function enter(uint256 x) external payable nonReentrant {


        //Verifying that the game is active.
        require(
            isGameActive,
            "Apologies, Cosmoonauts. We've put the launch on hold while we solve some minor technical issues."
        );


        //Verifying that the launchpad is open and boarding is in progress.
        require(
            !launchingclosed,
            "Our apologies, the launchpad is currently closed. Please wait for the results of the current launch and be ready for the next one!"
        );

        //Ensuring that the cosmoonaut has the sufficient funds (fuel) for their requested number of seats.  
        require(
            msg.value == x * 2.5 ether,
            "We're sorry, Cosmoonaut, but you don't have enough fuel for the number of seats you've requested on our rocket!"
        );

        // We have to make sure that our spaceship doesn't exceed its capacity. This piece of code verifies that the desired number of seats are still available.
        uint256 remaining = parameters[0].threshold - launches[launches.length - 1].participants.length;
        require(x <= remaining, "Apologies Cosmoonauts, but we're at maximum capacity for this launch. Hold tight for the next one!");


        // Welcome aboard Cosmoonaut! By joining this stellar list, you're marking your participation in the current launch. You're not just a passenger, but an intrepid explorer aiming to reach the moon!
        for (uint256 i = 0; i < x; i++) {
            launches[launches.length - 1].participants.push(
                payable(msg.sender)
            );
        }

        // A slice of the fuel we've collected is transferred to mission control. It's not just for the nuts and bolts, it's to build bigger rockets, push boundaries, and explore even farther reaches of the universe.
        // Repartition of the fees
        uint256 totalValue = msg.value;
        uint256 partEntreprise = (totalValue * 25) / 1000; // 2.5%
        uint256 partFondateur = (totalValue * 625) / 100000; // 0.625% pour chaque fondateur soit 2.5 au total

        company.transfer(partEntreprise);
        fondateurF.transfer(partFondateur);
        fondateurEE.transfer(partFondateur);
        fondateurL.transfer(partFondateur);
        fondateurG.transfer(partFondateur);

        // Not there yet, but soon, a unique launchpad inscription NFT will commemorate your cosmic journey. Stay tuned!

        // As an OG Cosmoonaut, you're not just going on a journey, you're part of the journey. To commemorate your pioneering spirit, we're minting x FG Tokens. Keep them safe, they're your proof of participation and who knows what surprises await you in the cosmos!
        FGT.mint(msg.sender, x * 10**18);

        // And for the universal records, we're broadcasting a participant registration event. You're now part of the history of our exploration, brave Cosmoonaut!
        emit ParticipantRegistered(msg.sender, x * 10**18);

        // If the last seat on our cosmic ship has been secured by an intrepid Cosmoonaut...
        if (
            launches[launches.length - 1].participants.length ==
            parameters[0].threshold
        ) {
            // ...we prepare the ship's logbooks and the containers for the cosmic loot. The ship's logbook keeps a record of the used entries (EntreeUtilisee), and the containers store the rewards (prizes) that our Cosmoonauts will gather from their cosmic journey.
            for (uint i = 0; i < parameters[0].threshold; i++) {
                launches[launches.length - 1].prizes.push(0);
                launches[launches.length - 1].EntreeUtilisee.push(0);
                launches[launches.length - 1].numerosAleatoiresOrigine.push(0);
            }

            // Time to close the launchpad. Our ship is fully loaded, ready for an adventure to the unknown!
            launchingclosed = true;

            // We're broadcasting a message across all channels: The launchpad is closed. It's a bittersweet moment, but there will be more launches, promise!
            emit LaunchpadClosed();

            // The countdown has begun! With this event, we announce that the launch is officially starting. All Cosmoonauts, brace yourselves!
            emit LaunchStarted();

            // We change the flag to send the signal for generating the random numbers. These aren't just any numbers - these are the coordinates for the new planets our Cosmoonauts will be exploring. And with this, we embark on our search for hospitable planets!
            allParticipantsRegistered = true;
            
        }
    }
    



        // The cosmic dance of numbers has ended, and it's time to crown our Cosmo-whale, the brave pioneer leading our space odyssey!
        function pickw1() internal {
            // The whims of the universe have selected our first Cosmoonaut from the current launch. Their audacious spirit has earned them the richest planetary system, transforming them into a true cosmic whale!
            uint256 mainWinnerIndex = listeNombresAleatoires[0] %
                launches[launches.length - 1].participants.length;

            // The universe has anointed its bravest voyager! We're outfitting their cosmic persona to handle the tidal waves of stellar wealth awaiting.
            address payable mainWinner = payable(
                launches[launches.length - 1].participants[mainWinnerIndex]
            );

            // We inscribe the treasure of the universe to our cosmic ledger, acknowledging our lead Cosmoonaut's rightful claim to the untamed riches of the farthest reaches.
            launches[launches.length - 1].prizes[mainWinnerIndex] = parameters[0].mainprize;

            // Let's beam the cosmic wealth to our pioneer. Watch them transform into a glorious Cosmo-whale right before your eyes - interstellar finance at its finest!
            mainWinner.transfer(parameters[0].mainprize);

            // Lastly, we record the space-time coordinates (random number index) that guided us to our main Cosmoonaut. It's the indelible trace of their cosmic voyage.
            launches[launches.length - 1].EntreeUtilisee[mainWinnerIndex] = mainWinnerIndex;
            launches[launches.length - 1].numerosAleatoiresOrigine[mainWinnerIndex] = listeNombresAleatoires[0]; // Enregistrement du nombre aléatoire
        }




        // Now let's find out who among our brave Cosmoonauts will be joining our trailblazing Cosmo-whale in the adventure of a lifetime!
        function pickw2() internal {
            // The voyage continues, as we dive back into the cosmic dance of numbers to unveil our subsequent spacefaring heroes.
            for (uint256 i = 0; i < parameters[0].numberwinner2; i++) {
                address payable Winner2;
                bool winnerFound = false;

                // As we journey into the constellation of potential pioneers, the cosmic dance of numbers guides us.
                uint256 Winner2Index = listeNombresAleatoires[i + 1] % launches[launches.length - 1].participants.length;

                // As long as there's a prize to be won in the galaxy, let the star chase continue.
                while (!winnerFound) {


                    // But wait, has this Cosmoonaut already won a planet? We can't have one Cosmoonaut monopolizing the universe!
                    if (launches[launches.length - 1].prizes[Winner2Index] == 0) {
                        // Aha, we've found a new celestial pioneer! Let's get them prepped for the voyage.
                        Winner2 = payable(launches[launches.length - 1].participants[Winner2Index]);
                        // We mark this lucky Cosmoonaut's planetary claim on our cosmic ledger.
                        launches[launches.length - 1].prizes[Winner2Index] = parameters[0].prize2;
                        // And now, the most exhilarating part - the cosmic riches get beamed straight to our brave Cosmoonaut.
                        Winner2.transfer(parameters[0].prize2);
                        // Let's not forget to trace the cosmic coordinates that led us to our fortunate friend.
                        launches[launches.length - 1].EntreeUtilisee[Winner2Index] = listeNombresAleatoires[i + 1] % launches[launches.length - 1].participants.length;
                        launches[launches.length - 1].numerosAleatoiresOrigine[Winner2Index] = listeNombresAleatoires[i + 1];
                        // Mission accomplished, we can now set our sights on the next objective.
                        winnerFound = true;

                    } else if(Winner2Index == launches[launches.length - 1].participants.length - 1) {
                            // Uh-oh! Our last Cosmoonaut is already on an interstellar loot mission. No worries, our auto-navigation system recalculates the route to find the next closest Cosmoonaut who doesn't have a planet yet. Next stop, new adventures!
                        for (uint256 j = 0; j < launches[launches.length - 1].participants.length; j++) {
                            if (launches[launches.length - 1].prizes[j] == 0) {
                                 // We've discovered a fresh Cosmoonaut - their bravery and luck shining bright in the cosmos.
                                Winner2 = payable(launches[launches.length - 1].participants[j]);
                                // Again, we record this newfound cosmic claim onto our galactic map.
                                launches[launches.length - 1].prizes[j] = parameters[0].prize2;
                                // As before, we share the stellar wealth with our latest cosmic pioneer.
                                Winner2.transfer(parameters[0].prize2);
                                // We leave the cosmic breadcrumb (random number) that led us to our new champion.
                                launches[launches.length - 1].EntreeUtilisee[j] = listeNombresAleatoires[i + 1] % launches[launches.length - 1].participants.length;
                                launches[launches.length - 1].numerosAleatoiresOrigine[j] = listeNombresAleatoires[i + 1];
                                // That's enough star chasing for now.
                                winnerFound = true;
                                break;
                            }
                        }
                    } else {
                        // Cosmic dust clouds are shifting, revealing more planets brimming with unknown treasures. We adjust our star chart (increment the index) to embark on new adventures, recruiting more Cosmoonauts for these unclaimed worlds.
                        Winner2Index++;
                    }
                }
            }
        }

        //  Time to reveal our constellation of Cosmoonauts who'll claim the third category planets using the cosmic dance of numbers!
        function pickw3() internal {
            // First, a quick check to make sure we're not venturing into unexplored space without any Cosmoonauts or launches.
            require(launches.length > 0, "No launches to pick winners from");
            Launch storage latestLaunch = launches[launches.length - 1];
            Parameters storage currentParameter = parameters[0];
            
            // Now let's make sure we've got worthy Cosmoonauts aboard our cosmic voyage.
            require(latestLaunch.participants.length > 0, "No participants to pick winners from");
            // As we prepare to unfold the cosmic dance, we need to ensure we have enough moves (random numbers) in our dance routine.
            require(listeNombresAleatoires.length >= 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3, "Not enough random numbers to pick winners");
            // Do we have more winners than participants? That's a cosmic faux pas we can't allow!
            require(currentParameter.numberwinner3 <= latestLaunch.participants.length, "More winners than participants");
            // Cosmic balance is essential! Let's ensure our prize and participant arrays match in length.
            require(latestLaunch.prizes.length == latestLaunch.participants.length, "Mismatch between prizes and participants arrays");
            // Finally, let's ensure that our prizes array is correctly initialized for this interstellar journey.
            require(latestLaunch.prizes.length == currentParameter.threshold, "Prizes array not initialized correctly");


            // Now, let's journey through the cosmos and crown our category 3 planet claimers!
            for (uint256 m = 0; m < currentParameter.numberwinner3; m++) {
                address payable Winner3;
                bool winnerFound2 = false;

                // The cosmic dance unfolds, guiding us through the constellation of potential pioneers.
                uint256 Winner3Index = listeNombresAleatoires[m + 1 + currentParameter.numberwinner2] % latestLaunch.participants.length;
                
                while (!winnerFound2) {

                    // Hold on, has this Cosmoonaut already claimed a planet? We can't have one Cosmoonaut monopolizing the universe!
                    if (latestLaunch.prizes[Winner3Index] == 0) {
                        // Brilliant, we've found another spacefarer! Let's prepare them for the voyage.
                        Winner3 = payable(latestLaunch.participants[Winner3Index]);
                        // Their cosmic claim is recorded in our star chart.
                        latestLaunch.prizes[Winner3Index] = currentParameter.prize3;
                        // As is the tradition, the cosmic riches get transferred to our brave Cosmoonaut.
                        Winner3.transfer(currentParameter.prize3);
                        // We'll remember the cosmic coordinates that brought us here.
                        latestLaunch.EntreeUtilisee[Winner3Index] = listeNombresAleatoires[m + 1 + currentParameter.numberwinner2] % latestLaunch.participants.length;
                        latestLaunch.numerosAleatoiresOrigine[Winner3Index] = listeNombresAleatoires[m + 1 + currentParameter.numberwinner2];

                        // Mission accomplished! The universe reveals more cosmic treasures for us to uncover.
                        winnerFound2 = true;
                    } else if(Winner3Index == latestLaunch.participants.length - 1) {
                        // Our last Cosmoonaut is already on a loot mission. The system recalculates the route to the next closest Cosmoonaut who doesn't have a planet yet.
                        for (uint256 k = 0; k < latestLaunch.participants.length; k++) {
                            if (latestLaunch.prizes[k] == 0) {
                                // We've found a new cosmic pioneer. Let's get them prepped for the voyage.
                                Winner3 = payable(latestLaunch.participants[k]);
                                // Their stellar claim is recorded onto our galactic map.
                                latestLaunch.prizes[k] = currentParameter.prize3;
                                // As always, we beam the celestial wealth straight to our Cosmoonaut.
                                Winner3.transfer(currentParameter.prize3);
                                // The cosmic breadcrumb (index) that led us to our new champion is traced.
                                latestLaunch.EntreeUtilisee[k] = listeNombresAleatoires[m + 1 + currentParameter.numberwinner2] % latestLaunch.participants.length;
                                latestLaunch.numerosAleatoiresOrigine[k] = listeNombresAleatoires[m + 1 + currentParameter.numberwinner2];

                                // Let's call off the star chase for now.
                                winnerFound2 = true;
                                break;
                            }
                        }
                    } else {
                        // More unclaimed stars gleam in the distance, beckoning us. We adjust our star chart (increment the index) to embark on new quests.
                        Winner3Index++;
                    }

                }
            }
        }


        //  Let's embark on the next phase of our cosmic journey - unveiling the daring Cosmoonauts who will claim the Fourth category planets!
        //  Our starmap guides us through the cosmos, revealing the lucky pioneers who'll share in the celestial bounty of the Fourth category.
        //  Each fortunate Cosmoonaut will see their star-bound ambitions materialize, as the Fourth category planets fall under their dominion!

        function pickw4() internal {
            // First, a quick check to make sure we're not venturing into unexplored space without any Cosmoonauts or launches.
            require(launches.length > 0, "No launches to pick winners from");
            Launch storage latestLaunch = launches[launches.length - 1];
            Parameters storage currentParameter = parameters[0];
            
            // Now let's make sure we've got worthy Cosmoonauts aboard our cosmic voyage.
            require(latestLaunch.participants.length > 0, "No participants to pick winners from");
            // As we prepare to unfold the cosmic dance, we need to ensure we have enough moves (random numbers) in our dance routine.
            require(listeNombresAleatoires.length >= 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3 + currentParameter.numberwinner4, "Not enough random numbers to pick winners");
            // Do we have more winners than participants? That's a cosmic faux pas we can't allow!
            require(currentParameter.numberwinner4 <= latestLaunch.participants.length, "More winners than participants");
            // Cosmic balance is essential! Let's ensure our prize and participant arrays match in length.
            require(latestLaunch.prizes.length == latestLaunch.participants.length, "Mismatch between prizes and participants arrays");
            // Finally, let's ensure that our prizes array is correctly initialized for this interstellar journey.
            require(latestLaunch.prizes.length == currentParameter.threshold, "Prizes array not initialized correctly");


            // Now, let's journey through the cosmos and crown our category 3 planet claimers!
            for (uint256 p = 0; p < currentParameter.numberwinner4; p++) {
                address payable Winner4;
                bool winnerFound3 = false;

                // The cosmic dance unfolds, guiding us through the constellation of potential pioneers.
                uint256 Winner4Index = listeNombresAleatoires[p + 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3] % latestLaunch.participants.length;
                
                while (!winnerFound3) {

                    // Hold on, has this Cosmoonaut already claimed a planet? We can't have one Cosmoonaut monopolizing the universe!
                    if (latestLaunch.prizes[Winner4Index] == 0) {
                        // Brilliant, we've found another spacefarer! Let's prepare them for the voyage.
                        Winner4 = payable(latestLaunch.participants[Winner4Index]);
                        // Their cosmic claim is recorded in our star chart.
                        latestLaunch.prizes[Winner4Index] = currentParameter.prize4;
                        // As is the tradition, the cosmic riches get transferred to our brave Cosmoonaut.
                        Winner4.transfer(currentParameter.prize4);
                        // We'll remember the cosmic coordinates that brought us here.
                        latestLaunch.EntreeUtilisee[Winner4Index] = Winner4Index;
                        latestLaunch.numerosAleatoiresOrigine[Winner4Index] = listeNombresAleatoires[p + 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3];

                        // Mission accomplished! The universe reveals more cosmic treasures for us to uncover.
                        winnerFound3 = true;
                    } else if(Winner4Index == latestLaunch.participants.length - 1) {
                        // Our last Cosmoonaut is already on a loot mission. The system recalculates the route to the next closest Cosmoonaut who doesn't have a planet yet.
                        for (uint256 q = 0; q < latestLaunch.participants.length; q++) {
                            if (latestLaunch.prizes[q] == 0) {
                                // We've found a new cosmic pioneer. Let's get them prepped for the voyage.
                                Winner4 = payable(latestLaunch.participants[q]);
                                // Their stellar claim is recorded onto our galactic map.
                                latestLaunch.prizes[q] = currentParameter.prize4;
                                // As always, we beam the celestial wealth straight to our Cosmoonaut.
                                Winner4.transfer(currentParameter.prize4);
                                // The cosmic breadcrumb (index) that led us to our new champion is traced.
                                latestLaunch.EntreeUtilisee[q] = Winner4Index;
                                latestLaunch.numerosAleatoiresOrigine[q] = listeNombresAleatoires[p + 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3];
                                // Let's call off the star chase for now.
                                winnerFound3 = true;
                                break;
                            }
                        }
                    } else {
                        // More unclaimed stars gleam in the distance, beckoning us. We adjust our star chart (increment the index) to embark on new quests.
                        Winner4Index++;
                    }

                }
            }
        }


        // Now that the cosmic voyage has concluded, it's time to reset and prepare for a new journey.
        function endrestart() internal {

            // What happens to the residual cosmic energy, you might wonder? For now, it's transferred back to the mission command - the contract owner.
            //These residual funds are destined to refuel our starship, powering the Chainlink automations for future voyages.
            // In the grand scheme of the cosmos, our ambition is to channel this energy directly into the Chainlink network, creating a self-sustaining, unstoppable force of cosmic exploration.
            LinkAutomation.transfer(address(this).balance); 

            // A new cosmic dance is about to unfold! We make an entry in our stellar diary for the upcoming cosmic voyage.
            launches.push();

            // The countdown begins anew. We reopen the launchpad for another thrilling cosmic adventure.
            launchingclosed = false;

            //  Emit an event to signal to all our Cosmoonauts across the universe that the launchpad is now closed, marking the end of one journey...
            emit LaunchpadClosed();

            // ... and the beginning of another. Emit an event to signal that a new cosmic voyage has started, reigniting the flame of excitement among our spacefarers.
            emit LaunchStarted();
        }
    //}


// Galactic Viewing Ports
// Cast your gaze upon the bold Cosmoonauts, their stellar spoils, and the cosmic numbers that charted their destiny.
    function getParticipants(uint256 launchNumber) public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        // Hone your telescope on a specific interstellar expedition, designated by the launch number.
        Launch memory launch = launches[launchNumber];
        // Bring into focus the details of our fearless Cosmoonauts, the celestial bounty they've acquired, and the guiding stars that set their course.
        return (launch.participants, launch.prizes, launch.EntreeUtilisee, launch.numerosAleatoiresOrigine);
    }


//A Cosmic Routine
    function drawnumbers() internal {
        Parameters storage currentParameter = parameters[0];

        // Calculating the count of habitable planets within our reach - the number of surviving Cosmoonauts eligible for the new world's bounty
        uint256 nombregagnants = 1 + currentParameter.numberwinner2 + currentParameter.numberwinner3 + currentParameter.numberwinner4;
        
        // Requesting fresh coordinates for the next cosmic exploration. Our interstellar navigation system is working tirelessly to discover all exploitable planets in this vast cosmos.
        demanderNombresAleatoires (nombregagnants);

        // All Cosmoonauts on board, our interstellar navigation system is mapping the trajectory to the next habitable planets. Let the countdown for our next cosmic exploration commence!

    }
    


    function runLottery() internal {
        // Our navigation system has done its job, it's time to reveal the coordinates of our newly discovered habitable planets. Let's meet our celestial pioneers!
        pickw1();
        pickw2();
        pickw3();
        pickw4();
        
        // Wiping the star map clean of used cosmic coordinates. No one wants to visit an already looted planet, after all!
        effacerNombresAleatoires();

        // Our launch mission concludes. Condolences to the brave Cosmoonauts we've lost, and let the preparations for the next cosmic adventure commence!
        endrestart();
        
    }



// The automaton guiding our celestial course - Chainlink Upkeep

    function checkUpkeep(bytes calldata checkData) public view override returns (bool upkeepNeeded, bytes memory performData) {
        // Decisions abound at the helm of our cosmic journey. When our spaceship registers a full complement of intrepid Cosmoonauts, it initiates a wide scan of the cosmos, sending out a request for celestial coordinates of resource-rich planets. Upon receipt of this crucial data, our navigation system leaps into action, divvying up the discovered celestial bodies among the Cosmoonauts who have yet to stake their claim on a new world.
        upkeepNeeded = randomNumberGenerated || allParticipantsRegistered;

        // We don't require any specific maintenance data in our cosmic journey.
        // Therefore, we return our received checkData as performData.
        performData = checkData;
    }

    function performUpkeep(bytes calldata /*performData*/) public override {
        // We ensure our celestial course still requires an adjustment.
        require(randomNumberGenerated || allParticipantsRegistered, "No upkeep needed");
        
        //Have the celestial coordinates of resource-rich planets reached us? Ignite the hyperdrives! It's time to launch the exploration mission and distribute the interstellar spoils among the fortunate Cosmoonauts
        if (randomNumberGenerated) {
            randomNumberGenerated = false;
            runLottery();
        }
        
        // Is our spaceship teeming with brave Cosmoonauts? Power up the star mapping sequence! We are now setting course to chart the undiscovered galaxies and their bountiful planets.
        if (allParticipantsRegistered) {
            allParticipantsRegistered = false;
            drawnumbers();
        }

        
    }


    // A celestial beacon to help ground control keep track of our galactic trajectory
    function checkRandomNumberGenerated() public view returns (bool) {
        return randomNumberGenerated;
    }

    // This is the way we use to know how many missions there is. How many promotions of proud cosmoonauts exists.
    function getLaunchCount() public view returns (uint256) {
        return launches.length;
    }

//Guardians of the Galaxy
// Only the chosen one, the creator of FG, can make certain adjustments to the cosmic journey.
    modifier onlyFGCreator() {
        require(msg.sender == Owner, "Not a creator of FG");
            _;
        }
        //
    }