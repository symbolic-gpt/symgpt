// File: contracts/DAONft.sol


pragma solidity ^0.8.17;

contract DaoNft{

    uint256 PerNFTPrice;
    uint256 NFTLimit = 10000;
    uint256 NFTsInMarket = 0;
    address public owner;

    struct OwnerDetails{
        bool exists;
        address user;
        uint256 nftsOwned;
    }

    mapping(address=>OwnerDetails) public DAONFtOwners;
    address[] public userAddresses;
    
    event _NFTMinted(
        address indexed mintedBy,
        uint256 nftCount,
        uint256 nftPrice,
        uint256 totalPrice,
        uint256 indexed timeStamp
    );
    event _NFTTransfered(
        address indexed fromUser,
        address indexed toUser,
        uint256 totalNfts,
        uint256 sellingPrice,
        uint256 totalAmount,
        uint256 indexed timeStamp
    );

    constructor(uint256 _perNFTPrice) { 
        owner = msg.sender;
        PerNFTPrice = _perNFTPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Only the owner can call this function.");
        _;  // Continue with the execution if the owner checks pass
    }


    /**
     * @dev - Mint the DAO NFTs for the user who is calling this function.
     * @param _totalNFTsToPurchase - Total number of nfts to be added for current user.
     */
    function mintDAONFT(uint256 _totalNFTsToPurchase) external {
        if( (NFTsInMarket+_totalNFTsToPurchase) > NFTLimit ){
            revert("Can not mint NFT, maximum limit exceeds.");
        }
        // If the owner already exists, update the nftsOwned parameter
        if (DAONFtOwners[msg.sender].exists) {
            DAONFtOwners[msg.sender].nftsOwned += _totalNFTsToPurchase;
        } else {
            // If the owner doesn't exist, create a new entry in the mapping
            DAONFtOwners[msg.sender] = OwnerDetails({
                exists: true,
                user: msg.sender,
                nftsOwned: _totalNFTsToPurchase
            });
            userAddresses.push(msg.sender);
        }
        NFTsInMarket += _totalNFTsToPurchase;
        uint256 totalAmount = PerNFTPrice * _totalNFTsToPurchase;
        emit _NFTMinted(msg.sender,_totalNFTsToPurchase,PerNFTPrice,totalAmount,block.timestamp);
    }

    /**
     * @dev - Returns the total number of NFTs owned for given user address 
     * @param _userAddress - address on which NFTs count to be returned.
     * @return - Retuns the total NFTS owned.
     */
    function getNftsOwned(address _userAddress) external view returns (uint256) {
        require(DAONFtOwners[_userAddress].exists, "User not found");
        return DAONFtOwners[_userAddress].nftsOwned;
    }

    /**
     * @dev - Transfer the DAO NFTs between two users.
     * @param _sendersAddress - Address from which NFTs to be deducted.
     * @param _receiversAddress - Address to which NFTs to be credited.
     * @param _totalNFTsToTrasnfer - Total number of nfts to be transfered.
     * @param _sellingPrice - Selling price of the NFTs set by senders
     */
    function transferDAONFT(address _sendersAddress, address _receiversAddress, uint256 _totalNFTsToTrasnfer, uint256 _sellingPrice) external {
        require(DAONFtOwners[_sendersAddress].exists, "Sender address not found.");
        require(DAONFtOwners[_receiversAddress].exists, "Receiver address not found.");

        DAONFtOwners[_sendersAddress].nftsOwned -= _totalNFTsToTrasnfer;
        DAONFtOwners[_receiversAddress].nftsOwned += _totalNFTsToTrasnfer;
        uint256 totalAmount = _sellingPrice * _totalNFTsToTrasnfer;
        emit _NFTTransfered(_sendersAddress,_receiversAddress,_totalNFTsToTrasnfer,_sellingPrice,totalAmount,block.timestamp);
    }

    /**
     * @dev To set the NFT per price for purchase.
     * @param _newPrice - Amount for per NFT price
     */
    function setNFTPerPrice(uint256 _newPrice) external onlyOwner{
        require(_newPrice !=0 ,"Invalid price received");
        PerNFTPrice = _newPrice;
    }

    /**
     * @dev Get the NFT per price for purchase.
     * @return - Returns the amount for purchase
     */
    function getNFTPerPrice() external view returns(uint256){
        return PerNFTPrice;
    }

    /**
     * @dev Get the NFT in cer.
     * @return - Returns the amount for purchase
     */
    function getNFTsInMarket() external view returns(uint256){
        return NFTsInMarket;
    }

    /**
     * @dev Get the NFT available to mint.
     * @return - Returns the NFT limit available for purchase
     */
    function getNFTsAvailableToMint() external view returns(uint256){
        return NFTLimit - NFTsInMarket;
    }

    /**
     * @dev - function to return all the users with their NFTs owned
     * @return 
     */
    function getAllUsersAndNftsOwned() external view returns (address[] memory, uint256[] memory) {
        uint256 totalUsers = userAddresses.length;
        
        address[] memory users = new address[](totalUsers);
        uint256[] memory nftsOwned = new uint256[](totalUsers);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalUsers; i++) {
            address tempAddress = userAddresses[i];
            users[currentIndex] = tempAddress;
            nftsOwned[currentIndex] = DAONFtOwners[tempAddress].nftsOwned;
            currentIndex++;
        }

        return (users, nftsOwned);
    }
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


/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol


pragma solidity ^0.8.0;


/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}

// File: @chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol


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
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
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
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
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
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig() external view returns (uint16, uint32, bytes32[] memory);

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(
    uint64 subId
  ) external view returns (uint96 balance, uint64 reqCount, address owner, address[] memory consumers);

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// File: contracts/RandomNumbers.sol


pragma solidity ^0.8.17;





/**
 * @title RandomNumbers
 * @author Bombaysoftwares
 * @notice Can generate the random numbers on the desired chain network using Chainlink
 */
contract RandomNumbers is VRFConsumerBaseV2, ConfirmedOwner {
    event _RequestFulfilled(uint256 indexed requestId, uint256[] randomNumbers);
    event _ConsumerAdded(uint64 indexed subcriptionId,address contractAddress);
    event _SubcriptionCreated(uint64 indexed subcriptionId);
    event _SubcriptionLinkFunded(uint64 indexed subcriptionId,uint amount);
    event _RequestSent(uint256 indexed requestId, uint32 numWords);

    // Assigning the coordinator key for desired network.
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    // The keyHash generated for your subscriptionID
    bytes32 keyHash;

    // The gas limit must be set, in-order to
    uint32 public callbackGasLimit;

    // For total numbers the request can be re-tried.
    uint16 requestConfirmations;

    // Makes the object, and stores the status of each requestID and its random number generated.
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomNumbers;
    }

    //Stores the requestID's and associated data as object.
    mapping(uint256 => RequestStatus) public s_requests;

    //LINK Token to be used for subcription funding
    uint32 public linkTokenAmount;

    // Subscription ID for chainlink VRF.
    uint64 public s_subscriptionId;

    // Setting the limit, to get the desired randomNumbers
    uint32 totalRandomNumbers;

    // Last transaction request Id.
    uint256 public lastRequestId;


    constructor(
        address _link_token_contract,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint32 _gasLimit,
        uint16 _requestConfirmations
    ) VRFConsumerBaseV2(_vrfCoordinator) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        callbackGasLimit = _gasLimit;
        requestConfirmations = _requestConfirmations;
        //Create a new subscription when you deploy the contract.
        LINKTOKEN = LinkTokenInterface(_link_token_contract);
        createNewSubscription();
    }

    /**
     * @dev - This is call back function, which will be called by the Chainlink VRF service when done regerating the random numbers.
     * @param _requestId - request id generated during request random words
     * @param _randomNums - Array of random numbers generated.
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomNums
    ) internal override {
        require(
            s_requests[_requestId].exists,
            "Invalid request ID or transaction failed"
        );
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomNumbers = _randomNums;
        emit _RequestFulfilled(_requestId, _randomNums);
    }

    /**
     * @dev This functions helps get the random numbers based on total count passed.
     * @param _randomNumCount - The total random numbers required.
     * @return requestId Random number function returns the requestID for transaction executed.
    */
    function requestRandomWords(
        uint32 _randomNumCount)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        totalRandomNumbers = _randomNumCount;
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            totalRandomNumbers
        );

        s_requests[requestId] = RequestStatus({
            randomNumbers: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        lastRequestId = requestId;
        emit _RequestSent(requestId, totalRandomNumbers);
        return requestId;
    }


    /**
     * @dev This function can used to override the gas fees which will be used in chainlink callback
     * @param _newGasLimit - This will be new gas limit
     * @return boolean
     */
    function setGasLimit(uint32 _newGasLimit) external onlyOwner returns(bool){
        callbackGasLimit = _newGasLimit;
        return true;
    }


    /**
     * @dev This function can used to override the Token LINKS which will be used in chainlink for funding the subscription id
     * @param _newAmount - This will be new gas limit
     * @return boolean
     */
    function setLinkAmount(uint32 _newAmount) external onlyOwner returns(bool){
        linkTokenAmount = _newAmount;
        return true;
    }

    /**
     * @dev Can be used to update the subscription ID, if ever needs to be changed
     * @param _newSubscriptionID - New subscription ID to be set 
     */
    function setSubscriptionId(uint64 _newSubscriptionID)external onlyOwner{
        s_subscriptionId = _newSubscriptionID;
    }

      /**
     * @dev This function is used to get the numbers present in the contract.
     * It searches the data based on the request id sent in request.
     * 
     * It accepts a range parameter, converting the uint256 number into our specified 
     * intermediate range.
     * Ex: if the range is set to 10, the function will return
     * a number within the range of 0 to 10. 
     * 
     * 
     * It also takes care of not returning duplicate numbers.
     * 
     * @param _requestId Requires the request id of recent/last trasaction requested for the random numbers 
     * @param _symbolsLength The random number generated is of type uint256 and must be transformed to fit within our preferred range. To achieve this, we apply the modulus operation with the length of symbols. Here it works as a range.
     */
    function getRequestStatus(
        uint256 _requestId,
        uint256 _symbolsLength,
        uint256 _packSize,
        uint256 _offset
    ) external view returns (uint256[] memory) {
        if(s_requests[_requestId].exists==false){
            revert("request not found.");
        }
        RequestStatus memory request = s_requests[_requestId];
        uint256[] memory randomNumberIndices = new uint256[](_packSize);
        
        uint256 randomNumberCount = 0;
        bool forceBreak = false;

        for (uint256 i = 0; i < _packSize; i++) {
            uint256 number  = (request.randomNumbers[i] % _symbolsLength);
            
            if(randomNumberCount==0){
                randomNumberIndices[randomNumberCount] = number;
                randomNumberCount++;
            }else{
                bool isNotDuplicate = true;

                for (uint256 j = 0; j < randomNumberCount; j++) {
                    if( randomNumberIndices[j] == number ){
                        i--;
                        _symbolsLength = _symbolsLength - _offset;
                        if (_symbolsLength < _packSize) {
                            forceBreak = true;
                            break;
                        }
                        isNotDuplicate = false;
                        break;
                    }
                }
                if(isNotDuplicate){
                    randomNumberIndices[randomNumberCount] = number;
                    randomNumberCount++;
                }
            }

            if(forceBreak){
                revert("Can not generate random numbers. Limit reached below pack size.");
            }
            if(randomNumberCount==_packSize){
                break;
            }
        }
        return randomNumberIndices;
    }

    /**
     * @dev Create a new subscription when the contract is initially deployed.
     * It creates the subscription and add itself as a consumer.
     * We can use s_subscriptionId to get the subsciption id and fund it before generating random numbers. 
     */
    function createNewSubscription() private onlyOwner {
        s_subscriptionId = COORDINATOR.createSubscription();
        emit _SubcriptionCreated(s_subscriptionId);
        // Add this contract as a consumer of its own subscription.
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
        emit _ConsumerAdded(s_subscriptionId,address(this));
    }

    /**
     * @dev This function helps to fund the subscription as and when needed.
     * In order to fund the subscription, the contract must have at least 0.5 LINK token.
     */
    function updateTokenLinksToSubcription()external onlyOwner{
        if(linkTokenAmount<=0){
            revert("Link token amount not set.");
        }
        if(s_subscriptionId==0){
            revert("Subscription ID not created.");
        }
        LINKTOKEN.transferAndCall(address(COORDINATOR), linkTokenAmount, abi.encode(s_subscriptionId));
        emit _SubcriptionLinkFunded(s_subscriptionId,linkTokenAmount);
    }

}

// File: @openzeppelin/contracts/utils/math/SignedMath.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: hardhat/console.sol


pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = 0x000000000000000000636F6e736F6c652e6c6f67;

	function _sendLogPayload(bytes memory payload) private view {
		address consoleAddress = CONSOLE_ADDRESS;
		/// @solidity memory-safe-assembly
		assembly {
			pop(staticcall(gas(), consoleAddress, add(payload, 32), mload(payload), 0, 0))
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts/ScalarNFT.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;






contract ScalarNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private nftId;
    uint256 public totalSupply = 0;
    uint256 private nonce = 0;
    string[] private scalarPositiveValues = [
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10"
    ];
    string[] private scalarNegativeValues = [
        "-2",
        "-3",
        "-4",
        "-5",
        "-6",
        "-7",
        "-8",
        "-9",
        "-10"
    ];

    string private baseURI = "https://ipfs.io/billions/scalar/";

    uint256 public mintPrice = 1 * 10 ** 6;


    mapping(uint256 => bool) private isMinted;
    mapping(uint256 => string) public scalarValueOfId;
    mapping(address => uint256[]) public scalarIdsOfPlayer;

    event MintNft(uint256 tokenId, address indexed user, string scalarValue);
    
    modifier NftOwner(uint256 tokenId) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not approved or owner"
        );
        _;
    }

    constructor() ERC721("Billions Scalar NFT", "BSN") {}

    /**
     * @notice Mint the scalar Nfts by spending ERC20 token
     * @return id returns the minted token id
     */
    function mint() external nonReentrant returns (uint256) {

        uint256 id = nftId.current();
        nftId.increment();

        _mint(msg.sender, id);
        totalSupply += 1;
        scalarIdsOfPlayer[msg.sender].push(id);

        uint256 reqId = getRandomNumber();
        string memory selectedValue;

        if (reqId < scalarPositiveValues.length) {
            selectedValue = scalarPositiveValues[reqId];
        } else {
            selectedValue = scalarNegativeValues[
                reqId - scalarPositiveValues.length
            ];
        }

        scalarValueOfId[id] = selectedValue;
        isMinted[id] = true;

        emit MintNft(id, msg.sender, selectedValue);

        return id;
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(!isMinted[tokenId], "Transfer not allowed for minted tokens");
        super.transferFrom(from, to, tokenId);
    }

    function getRandomNumber() internal returns (uint256) {
        nonce++;
        uint256 randomSeed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    msg.sender,
                    nonce
                )
            )
        );
        int256 maxRange = int256(scalarPositiveValues.length) +
            int256(scalarNegativeValues.length);
        return uint256(randomSeed % uint256(maxRange));
    }


    /**
     * store the price to mint(USDC)
     */
    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    /**
     * return the type and value of '_nftId' scalar nft
     */
    function getScalar(
        uint256 _nftId
    ) external view returns (string memory sValue) {
        if (_exists(_nftId)) {
            sValue = scalarValueOfId[_nftId];
        } else {
            return "";
        }
    }

    /**
     * store base of uri of ipfs for scalar nfts
     */
    function setBaseURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function addScalarPositiveValue(string memory value) external onlyOwner {
        scalarPositiveValues.push(value);
    }

    function removeScalarPositiveValue(string memory value) external onlyOwner {
        for (uint256 i = 0; i < scalarPositiveValues.length; i++) {
            if (
                keccak256(bytes(scalarPositiveValues[i])) ==
                keccak256(bytes(value))
            ) {
                if (i < scalarPositiveValues.length - 1) {
                    scalarPositiveValues[i] = scalarPositiveValues[
                        scalarPositiveValues.length - 1
                    ];
                }
                scalarPositiveValues.pop();
                break;
            }
        }
    }

    function addScalarNegativeValue(string memory value) external onlyOwner {
        scalarNegativeValues.push(value);
    }

    function removeScalarNegativeValue(string memory value) external onlyOwner {
        for (uint256 i = 0; i < scalarNegativeValues.length; i++) {
            if (
                keccak256(bytes(scalarNegativeValues[i])) ==
                keccak256(bytes(value))
            ) {
                if (i < scalarNegativeValues.length - 1) {
                    scalarNegativeValues[i] = scalarNegativeValues[
                        scalarNegativeValues.length - 1
                    ];
                }
                scalarNegativeValues.pop();
                break;
            }
        }
    }

    /**
     * @dev Burn an existing NFT.
     * @param tokenId The ID of the NFT to be burned.
     */
    function burn(uint256 tokenId) external NftOwner(tokenId) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not approved or owner"
        );
        _burn(tokenId);
    }

    /**
     * @dev Get the Owner NFT.
     * @param _tokenId The Token ID of the NFT.
     * @return Returns the owner of the NFT.
     */
    function getOwner(uint256 _tokenId) external view returns (address) {
        return ownerOf(_tokenId);
    }

    /**
     * return base of uri of ipfs for scalar nfts
     */
    function getBaseURI() external view returns (string memory) {
        return baseURI;
    }

    /**
     * return scalar info(scalarType, sclarValue) that '_user' player own
     */
    function getScalarsOfPlayer(
        address _user
    ) external view returns (string[] memory) {
        uint256[] memory scalarIds = scalarIdsOfPlayer[_user];
        uint256 count = scalarIds.length;
        string[] memory scalarInfos = new string[](count);

        for (uint256 i = 0; i < count; i++) {
            scalarInfos[i] = scalarValueOfId[scalarIds[i]];
        }

        return scalarInfos;
    }

    /**
     * return scalar ids that '_user' player own
     */
    function getScalarIdsOfPlayer(
        address _user
    ) external view returns (uint256[] memory) {
        return scalarIdsOfPlayer[_user];
    }
}

// File: contracts/TokenManager.sol


pragma solidity ^0.8.17;



contract TokenManager is Ownable {

    event _TokenTrasnfers(
        address indexed from, 
        address indexed to, 
        uint256 amount, 
        string currency, 
        address indexed stableCoinAddress,
        uint256 timeStamp,
        string paidFor);
    
    address private accountAddress;
    address private tokenAddress;
    string private tokenSymbol;
    IERC20 private tokenContract;

    address public battleContractAddress;
    address public billionsContractAddress;
    address public commissionContractAddress;
    address public marketplaceContractAddress;

    modifier onlyAllowedUsers() {
        require(msg.sender == accountAddress || msg.sender == battleContractAddress || msg.sender == billionsContractAddress || msg.sender == commissionContractAddress || msg.sender == marketplaceContractAddress, "Only authorised owner can call this function.");
        _;
    }

    constructor(address _tokenAddress, string memory _tokenSymbol){
        tokenAddress = _tokenAddress;
        tokenSymbol = _tokenSymbol;
        accountAddress = msg.sender;
        tokenContract = IERC20(_tokenAddress);
    }

    /**
     * @dev to transfer the amount to Admin from user
     *      This function would be called directly from the front-end of application
     * @param amount - Token amount
     * @param _paidFor - Purpose of the transfer
     */
    function makeTransfer(uint256 amount, string memory _paidFor) external {
        tokenContract.transferFrom(msg.sender, accountAddress, amount);
        emit _TokenTrasnfers(msg.sender, accountAddress, amount, tokenSymbol, tokenAddress,block.timestamp,_paidFor);
    }

    /**
     * @dev - This function will be called from the other contract or by admin in order to transfer amount.
     *        There could be varioud amount claim by user such as battle reward, jackpot reward and DAO Nft reward.
     * @param _to - users address to which amount is to be deducted
     * @param _amount - the amount to be transferd
     * @param _paidFor - The usecase for which the amount is transfered
     */
    function makeTransferTo(address _to, uint256 _amount, string memory _paidFor) external onlyAllowedUsers{
        tokenContract.transferFrom(accountAddress, _to, _amount);
        emit _TokenTrasnfers(accountAddress, _to, _amount, tokenSymbol, tokenAddress,block.timestamp,_paidFor);
    }
    
    /**
     * @dev - This function will be called from the other contract in order to transfer amount to admin.
     *        This is where the secondary sale commission would be transfered.
     * @param _from - users address to which amount is to be deducted
     * @param _amount - the amount to be transferd
     * @param _paidFor - The usecase for which the amount is transfered
     */
    function makeTransferToAdmin(address _from, uint256 _amount, string memory _paidFor) external onlyAllowedUsers{
        tokenContract.transferFrom(_from, accountAddress, _amount);
        emit _TokenTrasnfers(_from, accountAddress, _amount, tokenSymbol, tokenAddress,block.timestamp,_paidFor);
    }
    
    /**
     * @dev - This function will be called from the other contract in order to transfer amount to other.
     *        This is where one user transfers money to another user for secondary sale
     * @param _from - users address from which amount is to be deducted
     * @param _to - users address tp which amount is to be received
     * @param _amount - the amount to be transferd
     * @param _paidFor - The usecase for which the amount is transfered
     */
    function makeTransferToOthers(address _from, address _to, uint256 _amount, string memory _paidFor) external onlyAllowedUsers{
        tokenContract.transferFrom(_from, _to, _amount);
        emit _TokenTrasnfers(_from, _to, _amount, tokenSymbol, tokenAddress,block.timestamp,_paidFor);
    }

    /**
     * @dev - To set the battle contract address to execute few function with that address as owner
     * @param _newbattleContractAddress - the battle contract address 
     */
    function setBattleContractAddress(address _newbattleContractAddress) external onlyOwner{
        battleContractAddress = _newbattleContractAddress;
    }

    /**
     * @dev - To set the billions contract address to execute few function with that address as owner
     * @param _newbillionsContractAddress - the billions contract address 
     */
    function setBillionsContractAddress(address _newbillionsContractAddress) external onlyOwner{
        billionsContractAddress = _newbillionsContractAddress;
    }

    /**
     * @dev - To set the Commission tracker contract address to execute few function with that address as owner
     * @param _newcommissionContractAddress - the commission tracker contract address 
     */
    function setCommissionContractAddress(address _newcommissionContractAddress) external onlyOwner{
        commissionContractAddress = _newcommissionContractAddress;
    }

    /**
     * @dev - To set the marketplace contract address to execute few function with that address as owner
     * @param _newmarketplaceContractAddress - the marketplace contract address 
     */
    function setMarketplaceContractAddress(address _newmarketplaceContractAddress) external onlyOwner{
        marketplaceContractAddress = _newmarketplaceContractAddress;
    }
}

// File: contracts/CommissionRewardsTracker.sol


pragma solidity ^0.8.17;




contract CommissionRewardsTracker{

    DaoNft internal daoNFTContract;
    TokenManager internal tokenManagerContract;

    struct UserWinningData {
        uint256 rewards;
        uint256 recentTxnOn;
    }


    address public owner;
    address public battleContractAddress;
    uint256 JACKPOT_POOL_PERCENTAGE;

    // mapping(uint256 => uint256) public CommissionHistroy;
    mapping(uint256 => uint256) public JackPotPool;
    mapping(address => UserWinningData) public UserWinnings;

    mapping(address => uint256) public userBattleBalance;
    mapping(address => uint256) public userDaoBalance;

    mapping(address => mapping(uint256 => uint256)) public UserBattleRewards; //stores the amount w.r.t battle id
    mapping(address => mapping(uint256 => uint256)) public UserDAORewards; //stores the amount w.r.t battle id
    mapping(address => uint256) public UserJackpotRewards; //stores the amount w.r.t user address

    //uint currentMonth;
    mapping(uint256 => uint256) public totalJackpotForMonth;
    uint256[] public jackpotWinnersShare = [60,25,15];

    // Struct to store participation data for a user
    struct ParticipationData {
        uint battlesParticipated;
    }
    
    // Mapping to store participation data for each user in each month
    mapping(uint => mapping(address => ParticipationData)) public participationByMonth;
    RandomNumbers internal randomNumbersContract;


    event _CommissionStored(
        uint256 indexed battleId,
        uint256 commission,
        uint256 jackpotShare,
        uint256 daoNftShare,
        uint256 timestamp);

    event _DAORewardSummary(
        uint256 indexed battle,
        address[] users,
        uint256[] rewards,
        uint256 timeStamp);

    event _JackpotPoolSummary(
        uint256 indexed battle,
        uint256 rewards,
        uint256 timeStamp,
        uint256 jackpotFor);
    
    event _ClaimRewardSummary(
        address user,
        uint256[] battleList,
        uint256[] rewards
    );
    
    event _ClaimDAORewardSummary(
        address user,
        uint256[] battleList,
        uint256[] rewards
    );
    
    event _JackpotDistribution(
        address[] winnersList,
        uint256[] winnersReward,
        uint256 indexed jackpotFor
    );

    event _ClaimJackpotRewardSummary(
        address indexed user,
        uint256 reward
    );


    constructor(
        address _daoNFTContractAddress,
        uint256 _jackpotPoolPercentage,
        address _tokenManagerAddress,
        address _randomNumbersAddress
        ) {
        daoNFTContract = DaoNft(_daoNFTContractAddress);
        JACKPOT_POOL_PERCENTAGE = _jackpotPoolPercentage;
        tokenManagerContract = TokenManager(_tokenManagerAddress);
        randomNumbersContract = RandomNumbers(_randomNumbersAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == battleContractAddress, "Ownable: Only the owner can call this function.");
        _;
    }

    /**
     * @dev - This fnction gives rewards to the battle winners. And alos divides the commission amount into two parts DAO NFT share holders and jackpot pool.
     * @param _battleId - battle id for which the commission is stored.
     * @param _rankHolders - The list of user address who won battle
     * @param _rankHoldersRewards - The list of the rewards for the users list
     * @param _battleCommission - Total commission take from the battle reward.
     * @param _jackPotFor - The jackpot for the given month to be stored [ format : year_month ]
     */
    function storeRewardCommission(
        uint256 _battleId, 
        address[] memory _rankHolders,
        uint256[] memory _rankHoldersRewards,
        uint256 _battleCommission,
        uint256 _jackPotFor
        ) external onlyOwner {
        // CommissionHistroy[_battleId] = _battleCommission;
        

        // Divide commission 
        uint256 jackpotPoolShare = (_battleCommission * JACKPOT_POOL_PERCENTAGE) / 100; // 30% for jackpot
        JackPotPool[_battleId] += jackpotPoolShare;

        totalJackpotForMonth[_jackPotFor] +=jackpotPoolShare;

        uint256 daoNftHoldersShare = _battleCommission - jackpotPoolShare; //70% for DAO NFT holders

        (address[] memory users, uint256[] memory nftsOwned) = daoNFTContract.getAllUsersAndNftsOwned();
        uint256 totalNFTsOwned = getTotalNFTsOwned(nftsOwned);
        uint256[] memory rewards = new uint256[](users.length);

        uint256 battleID = _battleId;
        for (uint256 i = 0; i < users.length; i++) {
            
            address tempUser = users[i];
            uint256 userCommissionShare = (daoNftHoldersShare * nftsOwned[i]) / totalNFTsOwned;
            rewards[i] = userCommissionShare;

            UserWinnings[tempUser].rewards += userCommissionShare;
            UserWinnings[tempUser].recentTxnOn = block.timestamp;
            userDaoBalance[tempUser] += userCommissionShare;
            UserDAORewards[tempUser][battleID] += userCommissionShare;

        }

        emit _DAORewardSummary(_battleId,users,rewards,block.timestamp);

        for (uint256 i = 0; i < _rankHolders.length; i++) {
            address tempUser = _rankHolders[i];

            UserWinnings[tempUser].rewards += _rankHoldersRewards[i];
            UserWinnings[tempUser].recentTxnOn = block.timestamp;

            userBattleBalance[tempUser] += _rankHoldersRewards[i];
            UserBattleRewards[tempUser][battleID] += _rankHoldersRewards[i];
        }

        emit _JackpotPoolSummary(_battleId,jackpotPoolShare,block.timestamp,_jackPotFor);

        emit _CommissionStored(_battleId, _battleCommission, jackpotPoolShare, daoNftHoldersShare, block.timestamp);
    }

    /**
     * @dev - To claim the battle winning reward
     * @param _battleId - The battle id for which the reward to be claimed
     * @param _rewardAmount - The amount to be calimed
     */
    function claimBattleReward(address _userAddress, uint256 _battleId, uint256 _rewardAmount)external {
        require(userBattleBalance[_userAddress] >= _rewardAmount, "Not enough rewards available to cliam");

        UserWinnings[_userAddress].rewards -=  _rewardAmount;
        UserWinnings[_userAddress].recentTxnOn = block.timestamp;

        uint256[] memory battleList = new uint256[](1);
        battleList[0] = _battleId;

        uint256[] memory rewardList = new uint256[](1);
        rewardList[0] = _rewardAmount;

        emit _ClaimRewardSummary(
            _userAddress,
            battleList,
            rewardList
        );
        userBattleBalance[_userAddress] -= _rewardAmount;
        UserBattleRewards[_userAddress][_battleId] -= _rewardAmount;
    }
    /**
     * @dev - To claim all the battle winning reward
     * @param _battleIds - The battle id list for which the reward to be claimed
     */
    function claimAllBattleReward(address _userAddress, uint256[] memory _battleIds)external {
        
        uint256 length = _battleIds.length;
        
        uint256[] memory battleList = new uint256[](length);
        uint256[] memory rewardList = new uint256[](length);
        uint256 totalRewardAmount;
        
        for(uint256 i=0; i<length; i++){

            uint256 battleId = _battleIds[i];
            uint256 rewardAmount = UserBattleRewards[_userAddress][battleId];

            UserWinnings[_userAddress].rewards -=  rewardAmount;
            UserWinnings[_userAddress].recentTxnOn = block.timestamp;
      
            battleList[i] = battleId;
            rewardList[i] = rewardAmount;
            totalRewardAmount += rewardAmount;

            userBattleBalance[_userAddress] -= rewardAmount;
            UserBattleRewards[_userAddress][battleId] -= rewardAmount;
        }

        if(length>0 && totalRewardAmount>0){

            tokenManagerContract.makeTransferTo(_userAddress,totalRewardAmount, "ClaimAllBattleReward");
            emit _ClaimRewardSummary(
                _userAddress,
                battleList,
                rewardList
            );

        }
    }

    /**
     * @dev - To claim all the DAO winning rewards.
     * @param _battleIdLits - The list of battle ids for which the reward to be claimed.
     */
    function claimAllDAORewards(uint256[] memory _battleIdLits)external {
        
        uint256 _totalRewardAmount;
        uint256 length = _battleIdLits.length;
        uint256[] memory battleList = new uint256[](length);
        uint256[] memory rewardList = new uint256[](length);

        for(uint256 i=0; i<length; i++){
            uint256 battleId = _battleIdLits[i];
            uint256 reward = UserDAORewards[msg.sender][battleId];

            battleList[i] = battleId;
            rewardList[i] = reward;

            UserWinnings[msg.sender].rewards -= reward;
            UserWinnings[msg.sender].recentTxnOn = block.timestamp;
            userDaoBalance[msg.sender] -= reward;
            UserDAORewards[msg.sender][battleId] -= reward;
            _totalRewardAmount += reward;
        }

        if(_totalRewardAmount>0){
            
            tokenManagerContract.makeTransferTo(msg.sender,_totalRewardAmount, "ClaimAllDAORewards");
            emit _ClaimDAORewardSummary(
                msg.sender,
                battleList,
                rewardList
            );
        }
        
    }

    function declareJackpotWinnerFromGroup(
        uint256[] memory _requestData,
        address[] memory _groupOneUsers,
        address[] memory _groupTwoUsers,
        address[] memory _groupThreeUsers,
        address[] memory _groupFourUsers,
        address[] memory _groupFiveUsers,
        uint256 _requestId
    )external onlyOwner {
        //_requestData[0] => jackpot for
        //_requestData[1] => winners count
        //_requestData[2] => group Count

        if(_requestData[2]==1){
            selectJackpotWinnerFromGroupOne(
                _groupOneUsers,
                 _requestData[1]);
        }else if(_requestData[2]==2){
            selectJackpotWinnerGroupTwo(
                _requestData,
                _groupOneUsers,
                _groupTwoUsers,
                 _requestId);
        }else if(_requestData[2]==3){
            selectJackpotWinnerGroupThree(
                _requestData,
                _groupOneUsers,
                _groupTwoUsers,
                _groupThreeUsers,
                 _requestId);
        }else if(_requestData[2]==4){
            selectJackpotWinnerGroupFour(
                _requestData,
                _groupOneUsers,
                _groupTwoUsers,
                _groupThreeUsers,
                _groupFourUsers,
                 _requestId);
        }else if(_requestData[2]==5){
            selectJackpotWinnerGroupFive(
                _requestData,
                _groupOneUsers,
                _groupTwoUsers,
                _groupThreeUsers,
                _groupFourUsers,
                _groupFiveUsers,
                 _requestId);
        }
    }

    /**
     * 
     * @param _winners - list of winners address
     * @param jackpotFor - jackpot of month year to be sitributed
     */
    function selectJackpotWinnerGroupOne(address[] memory _winners,uint256 jackpotFor)external onlyOwner {

        uint256[] memory jackpotRewards = new uint256[](1);
        jackpotRewards[0] = totalJackpotForMonth[jackpotFor];
        updateJackpotWinnersRewards(_winners,jackpotRewards);
        emit _JackpotDistribution(_winners, jackpotRewards, jackpotFor);
        
    }

    /**
     * 
     * @param _winners - list of winners address
     * @param jackpotFor - jackpot of month year to be sitributed
     */
    function selectJackpotWinnerFromGroupOne(address[] memory _winners,uint256 jackpotFor)internal {

        uint256[] memory jackpotRewards = new uint256[](1);
        jackpotRewards[0] = totalJackpotForMonth[jackpotFor];
        updateJackpotWinnersRewards(_winners,jackpotRewards);
        emit _JackpotDistribution(_winners, jackpotRewards, jackpotFor);
        
    }

    /**
     * To Select the jackpot winners from the pool of given different users group.
     * @param _requestData - The required data for the calculation
     * @param _groupOneUsers - Pack of user address group 1
     * @param _groupTwoUsers - Pack of user address group 2
     * @param _requestId - request id for the random numbers
     */
    function selectJackpotWinnerGroupTwo(
        uint256[] memory _requestData,
        address[] memory _groupOneUsers,
        address[] memory _groupTwoUsers,
        uint256 _requestId
    ) internal {
        //_requestData[0] => jackpot for
        //_requestData[1] => winners count
        //_requestData[2] => group Count

        uint256 jackpotPrice = totalJackpotForMonth[_requestData[0]];
        address[] memory winnersList = new address[](_requestData[1]);
        uint256[] memory winnersAmount = new uint256[](_requestData[1]);
        uint256[] memory groupSelectionIndices = randomNumbersContract.getRequestStatus(_requestId,5,2,1);

        uint256[] memory jackpotShare = new uint256[](2);

        jackpotShare[0] = jackpotWinnersShare[0];
        jackpotShare[1] = jackpotWinnersShare[1]+jackpotWinnersShare[2];

        uint256 usersCount = 0;
        uint256[] memory usedGroups = new uint256[](_requestData[1]);
        for(uint256 i = 0; i < 2; i++) {
            address[] memory selectedArray;

            if(groupSelectionIndices[i] == 0 && checkIsGroupUsed(usedGroups,usersCount,0) == false) {
                selectedArray = _groupOneUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 1 && checkIsGroupUsed(usedGroups,usersCount,1) == false) {
                selectedArray = _groupTwoUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else{
                
                if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,0) == false ){
                    selectedArray = _groupOneUsers;
                    usedGroups[usersCount] = 0;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,1) == false ){
                    selectedArray = _groupTwoUsers;
                    usedGroups[usersCount] = 1;
                }
            }
            if(selectedArray.length>=1){
                uint256 userIndex = randomNumbersContract.getRequestStatus(_requestId, selectedArray.length, 1,1)[0];
            
                winnersList[usersCount] = selectedArray[userIndex];
                winnersAmount[usersCount] = (jackpotPrice * jackpotShare[usersCount]) / 100;
                usersCount++;
            }
            
        }
        require(usersCount == _requestData[1], "Failed to select jackpot winners.");

        updateJackpotWinnersRewards(winnersList, winnersAmount);
        emit _JackpotDistribution(winnersList, winnersAmount, _requestData[0]);
    }

    /**
     * To Select the jackpot winners from the pool of given different users group.
     * 
     * @param _requestData - Contains the jackpot for and winners count at respective index
     * @param _groupOneUsers - Pack of user address group 1
     * @param _groupTwoUsers - Pack of user address group 2
     * @param _groupThreeUsers - Pack of user address group 3
     * @param _requestId - Request id for random number to pick group and users
     */
    function selectJackpotWinnerGroupThree(
        uint256[] memory _requestData,
        address[] memory _groupOneUsers,
        address[] memory _groupTwoUsers,
        address[] memory _groupThreeUsers,
        uint256 _requestId
    ) internal {
        //_requestData[0] => jackpot for
        //_requestData[1] => winners count
        //_requestData[2] => group Count

        require(_requestData[1] == jackpotWinnersShare.length, "Total number of winners and percentage list length must be the same");

        uint256 jackpotPrice = totalJackpotForMonth[_requestData[0]];
        address[] memory winnersList = new address[](_requestData[1]);
        uint256[] memory winnersAmount = new uint256[](_requestData[1]);
        uint256[] memory groupSelectionIndices = randomNumbersContract.getRequestStatus(_requestId,5,3,1);

        uint256 usersCount = 0;
        uint256[] memory usedGroups = new uint256[](_requestData[1]);
        for(uint256 i = 0; i < 3; i++) {
            address[] memory selectedArray;

            if(groupSelectionIndices[i] == 0 && checkIsGroupUsed(usedGroups,usersCount,0) == false) {
                selectedArray = _groupOneUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 1 && checkIsGroupUsed(usedGroups,usersCount,1) == false) {
                selectedArray = _groupTwoUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 2 && checkIsGroupUsed(usedGroups,usersCount,2) == false) {
                selectedArray = _groupThreeUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else{
                
                if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,0) == false ){
                    selectedArray = _groupOneUsers;
                    usedGroups[usersCount] = 0;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,1) == false ){
                    selectedArray = _groupTwoUsers;
                    usedGroups[usersCount] = 1;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,2) == false ){
                    selectedArray = _groupThreeUsers;
                    usedGroups[usersCount] = 2;
                }
            }
            if(selectedArray.length>=1){
                uint256 userIndex = randomNumbersContract.getRequestStatus(_requestId, selectedArray.length, 1,1)[0];
            
                winnersList[usersCount] = selectedArray[userIndex];
                winnersAmount[usersCount] = (jackpotPrice * jackpotWinnersShare[usersCount]) / 100;
                usersCount++;
            }
            
        }
        require(usersCount == _requestData[1], "Failed to select jackpot winners.");

        updateJackpotWinnersRewards(winnersList, winnersAmount);
        emit _JackpotDistribution(winnersList, winnersAmount, _requestData[0]);
    }

 
    /**
     * To Select the jackpot winners from the pool of given different users group.
     * 
     * @param _requestData - Contains the jackpot for and winners count at respective index
     * @param _groupOneUsers - Pack of user address group 1
     * @param _groupTwoUsers - Pack of user address group 2
     * @param _groupThreeUsers - Pack of user address group 3
     * @param _groupFourUsers - Pack of user address group 4
     * @param _requestId - Request id for random number to pick group and users
     */
    
    function selectJackpotWinnerGroupFour(
        uint256[] memory _requestData,
        address[] memory _groupOneUsers,
        address[] memory _groupTwoUsers,
        address[] memory _groupThreeUsers,
        address[] memory _groupFourUsers,
        uint256 _requestId
    ) internal {
        //_requestData[0] => jackpot for
        //_requestData[1] => winners count
        //_requestData[2] => group Count

        require(_requestData[1] == jackpotWinnersShare.length, "Total number of winners and percentage list length must be the same");

        uint256 jackpotPrice = totalJackpotForMonth[_requestData[0]];
        address[] memory winnersList = new address[](_requestData[1]);
        uint256[] memory winnersAmount = new uint256[](_requestData[1]);
        uint256[] memory groupSelectionIndices = randomNumbersContract.getRequestStatus(_requestId,5,3,1);

        uint256 usersCount = 0;
        uint256[] memory usedGroups = new uint256[](_requestData[1]);
        for(uint256 i = 0; i < 3; i++) {
            address[] memory selectedArray;

            if(groupSelectionIndices[i] == 0 && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupOneUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 1 && checkIsGroupUsed(usedGroups,usersCount,1) == false ) {
                selectedArray = _groupTwoUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 2 && checkIsGroupUsed(usedGroups,usersCount,2) == false ) {
                selectedArray = _groupThreeUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 3 && checkIsGroupUsed(usedGroups,usersCount,3) == false ) {
                selectedArray = _groupFourUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else{
                
                if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,0) == false){
                    selectedArray = _groupOneUsers;
                    usedGroups[usersCount] = 0;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,1) == false){
                    selectedArray = _groupTwoUsers;
                    usedGroups[usersCount] = 1;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,2) == false){
                    selectedArray = _groupThreeUsers;
                    usedGroups[usersCount] = 2;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,3) == false){
                    selectedArray = _groupFourUsers;
                    usedGroups[usersCount] = 3;
                }
            }

            if(selectedArray.length>=1){
                uint256 userIndex = randomNumbersContract.getRequestStatus(_requestId, selectedArray.length, 1,1)[0];
            
                winnersList[usersCount] = selectedArray[userIndex];
                winnersAmount[usersCount] = (jackpotPrice * jackpotWinnersShare[usersCount]) / 100;
                usersCount++;
            }
        }

        require(usersCount == _requestData[1], "Failed to select jackpot winners.");

        updateJackpotWinnersRewards(winnersList, winnersAmount);
        emit _JackpotDistribution(winnersList, winnersAmount, _requestData[0]);
    }

    /**
     * To Select the jackpot winners from the pool of given different users group.
     * 
     * @param _requestData - Contains the jackpot for and winners count at respective index
     * @param _groupOneUsers - Pack of user address group 1
     * @param _groupTwoUsers - Pack of user address group 2
     * @param _groupThreeUsers - Pack of user address group 3
     * @param _groupFourUsers - Pack of user address group 4
     * @param _groupFiveUsers - Pack of user address group 5
     * @param _requestId - Request id for random number to pick group and users
     */
    function selectJackpotWinnerGroupFive(
        uint256[] memory _requestData,
        address[] memory _groupOneUsers,
        address[] memory _groupTwoUsers,
        address[] memory _groupThreeUsers,
        address[] memory _groupFourUsers,
        address[] memory _groupFiveUsers,
        uint256 _requestId
    ) internal {
        //_requestData[0] => jackpot for
        //_requestData[1] => winners count
        //_requestData[2] => group Count

        require(_requestData[1] == jackpotWinnersShare.length, "Total number of winners and percentage list length must be the same");

        uint256 jackpotPrice = totalJackpotForMonth[_requestData[0]];
        address[] memory winnersList = new address[](_requestData[1]);
        uint256[] memory winnersAmount = new uint256[](_requestData[1]);
        uint256[] memory groupSelectionIndices = randomNumbersContract.getRequestStatus(_requestId,5,3,1);

        uint256 usersCount = 0;
        uint256[] memory usedGroups = new uint256[](_requestData[1]);
        for(uint256 i = 0; i < 3; i++) {
            address[] memory selectedArray;

            if(groupSelectionIndices[i] == 0  && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupOneUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 1  && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupTwoUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 2  && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupThreeUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 3  && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupFourUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else if(groupSelectionIndices[i] == 4  && checkIsGroupUsed(usedGroups,usersCount,0) == false ) {
                selectedArray = _groupFiveUsers;
                usedGroups[usersCount] = groupSelectionIndices[i];
            }else{
                
                if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,0) == false){
                    selectedArray = _groupOneUsers;
                    usedGroups[usersCount] = 0;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,1) == false){
                    selectedArray = _groupTwoUsers;
                    usedGroups[usersCount] = 1;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,2) == false){
                    selectedArray = _groupThreeUsers;
                    usedGroups[usersCount] = 2;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,3) == false){
                    selectedArray = _groupFourUsers;
                    usedGroups[usersCount] = 3;
                }else if( checkIsGroupUsedCheckNext(usedGroups,usersCount,groupSelectionIndices,4) == false){
                    selectedArray = _groupFourUsers;
                    usedGroups[usersCount] = 4;
                }
            }

            if(selectedArray.length>=1){

                uint256 userIndex = randomNumbersContract.getRequestStatus(_requestId, selectedArray.length, 1,1)[0];
            
                winnersList[usersCount] = selectedArray[userIndex];
                winnersAmount[usersCount] = (jackpotPrice * jackpotWinnersShare[usersCount]) / 100;
                usersCount++;
            }
            
        }

        require(usersCount == _requestData[1], "Failed to select jackpot winners.");
        
        updateJackpotWinnersRewards(winnersList, winnersAmount);
        emit _JackpotDistribution(winnersList, winnersAmount, _requestData[0]);
    }

    /**
     * To Updated the jackpot winners reward in the mapping after selection.
     * @param _winners - list of users addresses
     * @param _rewards - list of users reward
     */
    function updateJackpotWinnersRewards(address[] memory _winners, uint256[] memory _rewards)internal {
        for(uint256 i = 0; i<_winners.length; i++){
            UserWinnings[_winners[i]].rewards += _rewards[i];
            UserWinnings[_winners[i]].recentTxnOn = block.timestamp;
            UserJackpotRewards[_winners[i]] += _rewards[i];
        }
    }

    /**
     * @dev - To check if the group is being used previosly while jackpot group selection.
     * @param _list - list of the groups selected.
     * @param _counter - represents the length of group ids selected
     * @param _find - To search the group id if its been used already
     * @return bool - Returns the boolean flag true if used else false.
     */
    function checkIsGroupUsed(uint256[] memory _list,uint256 _counter,uint256 _find)private pure returns(bool){
        bool flag = false;
        for(uint256 i=0; i<_counter;i++){
            if(_list[i] == _find){
                flag = true;
                break;
            }
        }
        return flag;
    }

    /**
     * To check the if the current group selection is used or not.
     * Also checks if it will be used in the next iteration call.
     * @param _list - list of the groups selected.
     * @param _counter - represents the length of group ids selected
     * @param _groupIndices - represents the actual group ids generated using chainlink
     * @param _find - To search the group id if its been used already or will be used in next iteration.
     */
    function checkIsGroupUsedCheckNext(uint256[] memory _list,uint256 _counter,uint256[] memory _groupIndices,uint256 _find)private pure returns(bool){
        bool isAlreadyUsed = false;
        bool isPresentNext = false;
        for(uint256 i=0; i<_counter;i++){
            if(_list[i] == _find){
                isAlreadyUsed = true;
                break;
            }
        }
        for(uint256 i=0; i<_groupIndices.length;i++){
            if(_groupIndices[i] == _find){
                isPresentNext = true;
                break;
            }
        }
        if(isAlreadyUsed == false && isPresentNext == false){
            return false;
        }else{
            return true;
        }
    }

    /**
     * To Set the new jackpot winners share for 3 users.
     * @param _newShare - new share value for 3 jackpot winners
     */
    function setJackpotWinnersNewShare(uint256[] memory _newShare)external onlyOwner{
        for(uint256 i =0; i<jackpotWinnersShare.length; i++){
            jackpotWinnersShare[i] = _newShare[i];
        }
    }
    
    /**
     * @dev - To claim the jackpot reward for user
     */
    function claimJackpotReward()external {
        
        uint256 _rewardAmount = UserJackpotRewards[msg.sender];
        require(_rewardAmount>0,"Insufficient jackpot balance.");

        UserWinnings[msg.sender].rewards -= _rewardAmount;
        UserWinnings[msg.sender].recentTxnOn = block.timestamp;

        UserJackpotRewards[msg.sender] -= _rewardAmount;

        tokenManagerContract.makeTransferTo(msg.sender,_rewardAmount, "ClaimJackpotReward");

        emit _ClaimJackpotRewardSummary(
            msg.sender,
            _rewardAmount
        );
    }

    /**
     * @dev To get the total Jackpot amount for given month year
     * @param _jackpotFor - Jackpot amount to be returned for given month. [ format : year_month ]
     * @return - Returns the total amount.
     */
    function getJackpotTotalForMonth(uint256 _jackpotFor) external view onlyOwner returns (uint256) {
        return totalJackpotForMonth[_jackpotFor];
    }


    /**
     * @dev To get the total of DAO NFTs used
     * @param nftsOwned - Array of the DAO NFTs count.
     * @return - Returns the total of NFTs count.
     */
    function getTotalNFTsOwned(uint256[] memory nftsOwned) internal pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < nftsOwned.length; i++) {
            total += nftsOwned[i];
        }
        return total;
    }

    /**
     * @dev - To get the amount of percentage set for the Jackpot pool
     * @return - Returns the amount of percentage set for jackpot pool
     */
    function getJackpotPoolShare()external view onlyOwner returns(uint256){
        return JACKPOT_POOL_PERCENTAGE;
    }

    /**
     * @dev - To the set the new percentage of the jackpot pool to be deducted from the commission
     * @param _newPercentage - The amount of percentage for jackpot pool
     */
    function setJackpotPoolShare(uint256 _newPercentage)external onlyOwner {
        JACKPOT_POOL_PERCENTAGE = _newPercentage;
    }

    /**
     * @dev - Set the token manager contract address, used to make money transfer.
     * @param _newAddress - The contract address of the deployed Token manager
     */
    function setTokenManagerContractAddress(address _newAddress)external onlyOwner {
       tokenManagerContract = TokenManager(_newAddress);
    }

    /**
     * @dev - Set the battle contract address, used to check if the owner or not.
     * @param _newAddress - The contract address of the deployed BattleContract
     */
    function setBattleContractAddress(address _newAddress)external onlyOwner {
        battleContractAddress = _newAddress;
    }

    /**
     * @dev - To Set the DAO NFT contract address, to able to fetch the users and their NFTs owned.
     * @param _newAddress - The contract address of the deployed DAO NFT contract
     */
    function setDaoNftContractAddress(address _newAddress)external onlyOwner {
        daoNFTContract = DaoNft(_newAddress);
    }

} 
// File: contracts/BillionsNFT.sol


pragma solidity ^0.8.17;











contract BillionsNFT is ERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;
    using Strings for address;
    using Counters for Counters.Counter;

    RandomNumbers internal randomNumbersContract;
    TokenManager internal tokenManagerContract;

    Counters.Counter private nftId;
    uint256 public totalSupply = 0;
    uint256 public maxMintLimit = 99999;

    address public marketplaceAddress;

    uint256 public defaultRentPrice = 1 * 10 ** 6;
    uint256 public defaultSellingPrice = 10 * 10 ** 6;

    string public baseURI = "https://ipfs.io/ipfs/";

    enum RenterStatus {
        PENDING,
        RENTER_USED,
        RENTER_CLAIMED
    }
    enum RentOwnerStatus {
        PENDING,
        AVAILABLE,
        OWNER_CLAIMED
    }

    struct NFTInfo {
        uint256 nftId;
        string symbol;
        string searchName;
        bool rentable;
        address owner;
        uint256 rentPrice;
        uint256 sellingPrice;
    }
    struct rentDetailsStruct {
        address owner;
        uint256 price;
        RenterStatus renterStatus;
        RentOwnerStatus ownerStatus;
    }
    struct UserNFTInfo{
        uint256 requestId;
        string[] symbols;
        bool exists;
    }

    mapping(address => UserNFTInfo[]) public nftsMinted;
    mapping(address => uint256) public rewardsFromRentedNfts;
    mapping(uint256 => address) public previousOwner;
    mapping(string => bool) private usedSymbol;
    mapping(uint256 => NFTInfo) public nftInfos; // nftId => NFT
    mapping(uint256 => mapping(uint256 => mapping(address => rentDetailsStruct)))
        public rentDetails;
    mapping(uint256 => mapping(address => uint256[]))
        public rentedTokenIdsOfUser;
    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        public rentInfos; // battle id => (nft id => (address => state))

    event _BillionsNftMint(
        uint256 tokenId,
        string symbol,
        address indexed owner
    );
    event TransferWithSymbol(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        string stockSymbol,
        string searchSymbol
    );
   
    event _UpdateRentalStatus(uint256 tokenId, uint256 price, bool isRental);
    event _RentNft(uint256 battleId, uint256[] tokenId, address indexed user);
    event _UpdateSellingPrice(uint256 tokenId, uint256 sellingPrice);

    event _NFTsMinted(
        address indexed owner,
        string[] symbols,
        string[] symbolNames,
        uint256[] tokenId,
        uint256 requestId,
        string exchangeType
    );

    modifier validAddress(address _to,address _sender){
        require(_to == _sender || _sender == marketplaceAddress, "Not allowed to make request");
        _;
    }

    modifier TokenOwned(uint256 _tokenId) {
        require(msg.sender == ownerOf(_tokenId), "only nft owner can edit");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _randomNumbersAddress,
        address _tokenManagerAddress
    ) ERC721(_name, _symbol) {

        randomNumbersContract = RandomNumbers(_randomNumbersAddress);
        tokenManagerContract = TokenManager(_tokenManagerAddress);
    }
    
    function mint(
        address _to,
        string memory _symbol,
        string memory _searchName
    ) public nonReentrant validAddress(_to,msg.sender) returns (uint256) {
        require(!usedSymbol[_symbol], "NFT already minted,can not mint twice.");
        require( (totalSupply+1) <= maxMintLimit, "Can not mint. Limit reached.");

        uint256 _nftId = nftId.current();
        nftId.increment();
        totalSupply += 1;

        _safeMint(_to, _nftId);
        emit TransferWithSymbol(
            msg.sender,
            address(0),
            _nftId,
            _symbol,
            _searchName
        );

        NFTInfo storage nftInfo = nftInfos[_nftId];
        nftInfo.nftId = _nftId;
        nftInfo.symbol = _symbol;
        nftInfo.rentable = false;
        nftInfo.rentPrice = defaultRentPrice;
        nftInfo.sellingPrice = defaultSellingPrice;
        nftInfo.owner = _to;
        nftInfo.searchName = _searchName;

        usedSymbol[_symbol] = true;

        emit _BillionsNftMint(_nftId, _symbol, _to);

        return _nftId;
    }

    function buyNFTPackApp(
        address _to,
        string[] memory _symbols,
        string[] memory _symbolNames,
        uint256 _packSize,
        uint256 _requestId,
        string memory _exchangeType) 
    external {
        
        require( (totalSupply + _packSize) <= maxMintLimit, "Can not mint. Limit reached.");
        uint256[] memory tokenIds = new uint256[](_packSize);
        for(uint256 i=0;i<_packSize;i++){
            tokenIds[i] = mint(_to,string(abi.encodePacked(_symbols[i], "_", _exchangeType)),_symbolNames[i]);
        }
        nftsMinted[_to].push(UserNFTInfo(_requestId,_symbols,true));
        emit _NFTsMinted(_to, _symbols,_symbolNames,tokenIds,_requestId,_exchangeType);
    }

    function buyNFTPack(
        address _to,
        string[] memory _symbols,
        string[] memory _symbolNames,
        uint256 _packSize,
        uint256 _requestId,
        string memory _exchangeType,
        uint256 _offset) 
    external returns(string[] memory){
        uint256[] memory randomNumbers = randomNumbersContract.getRequestStatus(_requestId,_symbols.length,_packSize,_offset);
       
        string[] memory symbolsList = new string[](_packSize);
        string[] memory symbolNamesList = new string[](_packSize);
        uint256[] memory tokenIds = new uint256[](_packSize);
        
        address callersAddress = _to;
        for(uint256 i=0;i<_packSize;i++){
            uint256 index = randomNumbers[i];
            string memory _symbolName = _symbolNames[index];
            symbolsList[i] = _symbols[index];
            symbolNamesList[i] = _symbolName;
            string memory symbolWithExchange = string(abi.encodePacked(_symbols[index], "_", _exchangeType));

            tokenIds[i] = mint(
                callersAddress,
                symbolWithExchange,
                _symbolName
            );
        }
        nftsMinted[_to].push(UserNFTInfo(_requestId,_symbols,true));
        emit _NFTsMinted(_to, symbolsList,symbolNamesList,tokenIds,_requestId,_exchangeType);
        return symbolsList;
    }


    function tokenURI(
        uint256 _nftId
    ) public view virtual override returns (string memory uri) {
        _requireMinted(_nftId);

        uri = bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, nftInfos[_nftId].symbol))
            : "";
    }

    function updateNftRentingStatus(
        uint256 _tokenId,
        uint256 _rentprice,
        bool status
    ) external nonReentrant TokenOwned(_tokenId) {
        if (ownerOf(_tokenId) == marketplaceAddress) {
            require(
                msg.sender == previousOwner[_tokenId],
                "only nft owner can edit"
            );
        } else {
            require(msg.sender == ownerOf(_tokenId), "only nft owner can edit");
        }

        NFTInfo storage nftInfo = nftInfos[_tokenId];

        nftInfo.rentPrice = _rentprice;
        nftInfo.rentable = status;

        emit _UpdateRentalStatus(_tokenId, _rentprice, nftInfo.rentable);
    }

    function updateSellingPrice(
        uint256 _tokenId,
        uint256 _newSellingPrice
    ) external nonReentrant TokenOwned(_tokenId){
        if (ownerOf(_tokenId) == marketplaceAddress) {
            require(
                msg.sender == previousOwner[_tokenId],
                "only nft owner can edit"
            );
        } else {
            require(msg.sender == ownerOf(_tokenId), "only nft owner can edit");
        }

        NFTInfo storage nftInfo = nftInfos[_tokenId];
        nftInfo.sellingPrice = _newSellingPrice;

        emit _UpdateSellingPrice(_tokenId, _newSellingPrice);
    }

    function setMarketplaceAddress(
        address _newMarketplaceAddress
    ) external onlyOwner {
        marketplaceAddress = _newMarketplaceAddress;
    }

    function rentAnNft(uint256 _battleId, uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            require(_exists(tokenId), "token id not exist");

            NFTInfo memory nftInfo = nftInfos[tokenId];
            require(nftInfo.rentable, "token is not available for rent");

            address to;

            if (nftInfo.owner == marketplaceAddress) {
                to = previousOwner[tokenId];
            } else {
                to = nftInfo.owner;
            }

            rentDetailsStruct storage _rentDetails = rentDetails[_battleId][
                tokenId
            ][msg.sender];

            _rentDetails.owner = to;
            _rentDetails.price = nftInfo.rentPrice;
            _rentDetails.renterStatus = RenterStatus.PENDING;
            rentInfos[_battleId][tokenId][msg.sender] = true;
        }

        rentedTokenIdsOfUser[_battleId][msg.sender] = _tokenIds;

        emit _RentNft(_battleId, _tokenIds, msg.sender);
    }

    function useRentedNft(
        uint256 _battleId,
        uint256 _tokenId,
        address _renter
    ) external {
        rentDetailsStruct storage _rentDetails = rentDetails[_battleId][
            _tokenId
        ][_renter];

        rewardsFromRentedNfts[_rentDetails.owner] += _rentDetails.price;
        tokenManagerContract.makeTransferToOthers(_renter,_rentDetails.owner,_rentDetails.price,"RentFromNFT");
    }

    function getOwner(uint256 _tokenId) external view returns (address) {
        return ownerOf(_tokenId);
    }

    function isRenter(
        uint256 _bttleId,
        uint256 _nftId,
        address _addr
    ) external view returns (bool) {
        return rentInfos[_bttleId][_nftId][_addr];
    }

    function updatePreviousOwner(
        uint256 _tokenId,
        address _previousOwner
    ) external {
        previousOwner[_tokenId] = _previousOwner;
    }

    function getPreviousOwner(
        uint256 _tokenId
    ) public view returns (address owner) {
        return previousOwner[_tokenId];
    }

    function getRecentNftsToBeMinted()external view returns(UserNFTInfo memory){
        return nftsMinted[msg.sender][nftsMinted[msg.sender].length - 1];
    }
}

// File: contracts/BattleContract.sol


pragma solidity ^0.8.17;










contract BattleContract is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    CommissionRewardsTracker internal commissionRewardTrackerContract;
    TokenManager internal tokenManagerContract;
    enum BattleState {
        Betting,
        Started,
        Ended,
        Expired
    }

    //////////////////////////// Game parameters ///////////////////////////
    uint256[4] public rankPercent = [50, 100, 200, 450]; // x1000
    uint256[4] public rewardPercent = [300, 200, 200, 300]; // x1000
    uint256[5] public bonusPercent = [500, 250, 150, 75, 25]; // x1000
    uint256 public rakePercent = 7; // x100
    uint256 public leaderBonus = 2; // x100
    ////////////////////////////////////////////////////////////////////////

    uint256 public battlePeriod = 1 days;

    uint256 public sinkThreshold = 4000000 * 10 ** 18; // 4M PLAY tokens
    uint256 public quarterInterval = 30 days;

    address public billionsNftAddress;
    address public scalarNftAddress;
    address public marketplaceAddress;

    uint256 public reserveBalance;
    uint256 public lastUnlockTimestamp;

    uint256 public validWithdrawAmount = 0;

    uint256 public battleId = 1;

    uint256 BATTLE_PRIZE_COMMISSION;

    struct PlayerInfo {
        uint256[] nftIds;
        uint256[] scalarIds;
    }

    mapping(uint256 => mapping(address => PlayerInfo)) enteredPlayerInfos; // (battle id => (player address => PlayerInfo))
    mapping(uint256 => address[]) enteredPlayerAddress; // (battle id => player address)

    mapping(uint256 => mapping(address => uint256)) rewardsEveryBattle; // (battle id => (player address => reward))
    mapping(uint256 => mapping(address => bool)) isUserParticipatedBattle;

    mapping(address => bool) public isVerifiedPlayer;


    struct BattleInfo {
        uint256 battleId;
        string exchange;
        string country;
        uint256 battleType;
        address creator;
        uint256 nftCount;
        uint256 entryFee;
        uint256 epoch;
        uint256 extraRewards;
        uint256 startTime;
        uint256 endTime;
        BattleState state;
        string passcode;
    }
    mapping(uint256 => BattleInfo) battles; // battle id => BattleInfo
    mapping(uint256 => uint256[]) public battlesEveryEpoch; // epoch => array of battle ids

    event _Withdraw(address, uint256);
    event _CreateBattle(
        uint256 _battleId,
        address indexed owner,
        string exchange,
        string country,
        uint256 nftCount,
        uint256 entryFee,
        uint256 startTime,
        uint256 endTime,
        uint256 battleType,
        string passcode
    );
    event _BetBattle(
        uint256 _battleId,
        address indexed _playerAddress,
        uint256[] _nftIds,
        uint256[] _scalarIds
    );
    event _ClaimedReward(
        uint256 _battleId,
        address indexed _player,
        uint256 _amount
    );
    event _SendReward2Owner(
        uint256 _battleId,
        address indexed _creator,
        address _owner,
        uint256 _amount
    );
    event _BattleStateChanged(uint256 _battleId, uint256 state);
    event _EndBattle(
        uint256 battleId,
        address[] rankedHolders,
        uint256[] rewards
    );

    event _TopUpBattlePrize(
        uint256 battleId,
        uint256 newPrizeAmount,
        uint256 timeStamp
    );

    event _UpdateBattleCommission(
        uint256 oldCommission,
        uint256 newCommission,
        uint256 timeStamp
    );


    /**
     * player can only bet when the battle is in betting status
     */
    modifier Bettable(uint256 _battleId) {
        require(_battleId < battleId, "Battle identification error");
        require(
            battles[_battleId].state == BattleState.Betting,
            "You are not allowed to bet on this Battle"
        );
        require(
            block.timestamp < battles[_battleId].startTime,
            "Betting has already started"
        );
        _;
    }

    /**
     * player can only claim when the battle is ended
     */
    modifier Claimable(uint256 _battleId) {
        require(_battleId < battleId, "Battle identification error");
        require(
            battles[_battleId].state == BattleState.Ended,
            "Battle is not ended yet"
        );
        _;
    }

    /**
     * verified player can only create the battle
     */
    modifier onlyVerifiedPlayer() {
        require(isVerifiedPlayer[msg.sender] == true, "No verified player");
        _;
    }

    /**
     * '_addr' is wallet address of trusted forwarder address
     * timestamp of 1 day is 60 * 60 * 24 = 86400
     */
    constructor(
        address _commissionRewardTrackerAddress,
        address _billionsNftAddress,
        address _scalarNftAddress,
        address _marketplaceAddress,
        uint256 _battlePrizeCommisison,
        address _tokenManagerAddress
    ) {
        isVerifiedPlayer[msg.sender] = true;
        lastUnlockTimestamp = block.timestamp;

        commissionRewardTrackerContract = CommissionRewardsTracker(_commissionRewardTrackerAddress);
        tokenManagerContract = TokenManager(_tokenManagerAddress);
        billionsNftAddress = _billionsNftAddress;
        scalarNftAddress = _scalarNftAddress;
        marketplaceAddress = _marketplaceAddress;
        BATTLE_PRIZE_COMMISSION = _battlePrizeCommisison;
    }

    function _initialize(
        address _billionsNft,
        address _scalarNft
    ) external onlyOwner {
        billionsNftAddress = _billionsNft;
        scalarNftAddress = _scalarNft;
    }

    /**
     * '_battleType': 0 -> health battle, 1 -> blood battle
     * '_enterFee' is new entry fee defined by creator.
     * '_startTime' is the timestamp when betting will start
     * '_endTime' is the timestamp when betting will end
     *
     * - If 'battle.creatorAddress' is equal to 'owner', we can know this battle is created by owner.
     * - This function is called from backend (Game system creates 2 types of battle, health, and blood as default) or frontend (verified player creates battle).
     */
    function CreateBattle(
        uint256 _battleType,
        string memory _exchange,
        string memory _country,
        uint256 _enterFee,
        uint256 _nftCount,
        uint256 _startTime,
        uint256 _endTime,
        string memory _passcode
    ) external onlyVerifiedPlayer {
        require(_enterFee > 0, "Enter fee must be greater than 0");
        require(
            _endTime > _startTime,
            "End time must be greater than start time"
        );

        uint256 _currentBattleId = battleId;

        BattleInfo storage battle = battles[_currentBattleId];
        battle.battleId = _currentBattleId;
        battle.exchange = _exchange;
        battle.country = _country;
        battle.battleType = _battleType;
        battle.creator = msg.sender;
        battle.nftCount = _nftCount;
        battle.entryFee = _enterFee;
        battle.startTime = _startTime;
        battle.endTime = _endTime;
        battle.state = BattleState.Betting;
        battle.passcode = _passcode;

        battleId += 1;
        uint256 TypeBattle = _battleType;
        emit _CreateBattle(
            _currentBattleId,
            msg.sender,
            _exchange,
            _country,
            _nftCount,
            _enterFee,
            _startTime,
            _endTime,
            TypeBattle,
            _passcode
        );
    }

    /**
     * '_battleId' is the battle's ID the player is betting
     * '_nftIds' is the NFT's IDs selected by the player
     * '_scalarType' is the type of scalar, 0: non scalar, 1: multiplier, 2: negator, 3: index scalar
     *
     * - Player must pay the fee before betting.
     * - Betting is allowed only during the betting period.
     */
    function BetBattle(
        uint256 _battleId,
        uint256[] memory _nftIds,
        uint256[] memory _scalarIds,
        string memory _passcode
    ) external Bettable(_battleId) {
        BattleInfo memory battle = battles[_battleId];

        require(
            keccak256(abi.encodePacked(battle.passcode)) ==
                keccak256(abi.encodePacked(_passcode)),
            "passcode mismatch"
        );

        uint256 nftCount = _nftIds.length;
        require(battle.nftCount == nftCount, "NFT count error");
        require(
            !isUserParticipatedBattle[_battleId][msg.sender],
            "already participated in this battle"
        );

        isUserParticipatedBattle[_battleId][msg.sender] = true;

        uint256 i = 0;
        uint256 j = 0;
        for (i = 0; i < nftCount; i++) {
            for (j = i + 1; j < nftCount; j++) {
                require(_nftIds[i] != _nftIds[j], "Use of duplicated NFT");
            }
        }

        BillionsNFT billionsNFT = BillionsNFT(billionsNftAddress);
        ScalarNFT scalarNFT = ScalarNFT(scalarNftAddress);

        PlayerInfo storage player = enteredPlayerInfos[_battleId][msg.sender];

        for (i = 0; i < nftCount; i++) {
            uint256 _nftId = _nftIds[i];

            if (billionsNFT.getOwner(_nftId) != msg.sender) {
                if (billionsNFT.getOwner(_nftId) == marketplaceAddress) {
                    if (billionsNFT.getPreviousOwner(_nftId) != msg.sender) {
                        require(
                            billionsNFT.isRenter(_battleId, _nftId, msg.sender),
                            "nft is not rented"
                        );
                        billionsNFT.useRentedNft(_battleId, _nftId, msg.sender);
                    }
                } else {
                    require(
                        billionsNFT.isRenter(_battleId, _nftId, msg.sender),
                        "nft is not rented"
                    );
                    billionsNFT.useRentedNft(_battleId, _nftId, msg.sender);
                }
            }

            player.nftIds.push(_nftId);
        }

        for (i = 0; i < _scalarIds.length; i++) {
            uint256 _scalarId = _scalarIds[i];
            require(
                scalarNFT.getOwner(_scalarId) == msg.sender,
                "This scalar is owned by another player"
            );
            scalarNFT.burn(_scalarId);
            player.scalarIds.push(_scalarId);
        }

        enteredPlayerAddress[_battleId].push(msg.sender);

        emit _BetBattle(_battleId, msg.sender, _nftIds, _scalarIds);
    }

    function EndBattle(
        uint256 _battleId,
        address[] memory _rankHolders,
        uint256[] memory _rankHoldersRewards,
        uint256 _battleCommission,
        uint256 _jackPotFor
    ) external onlyOwner {
        require(_battleId < battleId, "Battle identification error");
        require(
            _rankHolders.length == _rankHoldersRewards.length,
            "Mismatch in lengths of user addresses and rewards arrays"
        );

        BattleInfo storage battle = battles[_battleId];

        require(
            battle.state == BattleState.Betting,
            "Battle have not started yet"
        );
        require(
            block.timestamp >= battle.startTime,
            "Battle cannot be cancelled before start"
        );
        

        for (uint256 i = 0; i < _rankHolders.length; i++) {
            
            address user = _rankHolders[i];
            uint256 reward = _rankHoldersRewards[i];

            rewardsEveryBattle[_battleId][user] = reward;
        }


        commissionRewardTrackerContract.storeRewardCommission(
            _battleId,
            _rankHolders,
            _rankHoldersRewards,
            _battleCommission,
            _jackPotFor
        );

        battle.state = BattleState.Ended;
        emit _BattleStateChanged(_battleId, uint256(BattleState.Ended));
        emit _EndBattle(_battleId, _rankHolders, _rankHoldersRewards);
    }


    function EndBattleTest(
        uint256 _battleId,
        address[] memory _rankHolders,
        uint256[] memory _rankHoldersRewards,
        uint256 _battleCommission,
        uint256 _jackPotFor
    ) external onlyOwner {
        require(_battleId < battleId, "Battle identification error");
        require(
            _rankHolders.length == _rankHoldersRewards.length,
            "Mismatch in lengths of user addresses and rewards arrays"
        );

        BattleInfo storage battle = battles[_battleId];

        for (uint256 i = 0; i < _rankHolders.length; i++) {
            
            address user = _rankHolders[i];
            uint256 reward = _rankHoldersRewards[i];

            rewardsEveryBattle[_battleId][user] = reward;
        }

        commissionRewardTrackerContract.storeRewardCommission(
            _battleId,
            _rankHolders,
            _rankHoldersRewards,
            _battleCommission,
            _jackPotFor
        );

        battle.state = BattleState.Ended;
        emit _BattleStateChanged(_battleId, uint256(BattleState.Ended));
        emit _EndBattle(_battleId, _rankHolders, _rankHoldersRewards);
    }

    function calculateRewards(
        uint256 _battleId,
        address[] memory _fivePercentileHolders,
        address[] memory _tenPercentileHolders,
        address[] memory _twentyPercentileHolders,
        address[] memory _fourtyFivePercentileHolders,
        uint256 _totalPrizePool
    ) private {
        mapping(address => uint256)
            storage rewardOfPlayers = rewardsEveryBattle[_battleId];

        uint256 _rank1Rewards = (_totalPrizePool * rewardPercent[0]) / 1000;
        uint256 _rank2Rewards = (_totalPrizePool * rewardPercent[1]) / 1000;
        uint256 _rank3Rewards = (_totalPrizePool * rewardPercent[2]) / 1000;
        uint256 _rank4Rewards = (_totalPrizePool * rewardPercent[3]) / 1000;

        for (uint256 i = 0; i < _fivePercentileHolders.length; i++) {
            require(
                isUserParticipatedBattle[_battleId][_fivePercentileHolders[i]],
                "user unauthorized"
            );
            rewardOfPlayers[_fivePercentileHolders[i]] += _rank1Rewards.div(
                _fivePercentileHolders.length
            );
        }
        for (uint256 i = 0; i < _tenPercentileHolders.length; i++) {
            require(
                isUserParticipatedBattle[_battleId][_tenPercentileHolders[i]],
                "user unauthorized"
            );
            rewardOfPlayers[_tenPercentileHolders[i]] += _rank2Rewards.div(
                _tenPercentileHolders.length
            );
        }
        for (uint256 i = 0; i < _twentyPercentileHolders.length; i++) {
            require(
                isUserParticipatedBattle[_battleId][
                    _twentyPercentileHolders[i]
                ],
                "user unauthorized"
            );
            rewardOfPlayers[_twentyPercentileHolders[i]] += _rank3Rewards.div(
                _twentyPercentileHolders.length
            );
        }
        for (uint256 i = 0; i < _fourtyFivePercentileHolders.length; i++) {
            require(
                isUserParticipatedBattle[_battleId][
                    _fourtyFivePercentileHolders[i]
                ],
                "user unauthorized"
            );
            rewardOfPlayers[_fourtyFivePercentileHolders[i]] += _rank4Rewards
                .div(_fourtyFivePercentileHolders.length);
        }
    }

    function calculateRewardsForLowParticipants(
        uint256 _battleId,
        uint256 _totalPrizePool,
        address[] memory _participants,
        uint16[5] memory _percents
    ) internal {
        mapping(address => uint256)
            storage rewardOfPlayers = rewardsEveryBattle[_battleId];

        for (uint256 i = 0; i < _participants.length; i++) {
            rewardOfPlayers[_participants[i]] += _totalPrizePool
                .mul(_percents[i])
                .div(1000);
        }
    }

    function setBonuses(
        uint256 _battleId,
        address[] memory _rank,
        uint256 _totalAmount
    ) private {
        uint256 _bonusPrizePool = _totalAmount.mul(leaderBonus).div(100);

        mapping(address => uint256)
            storage rewardOfPlayers = rewardsEveryBattle[_battleId];

        for (uint256 i = 0; i < _rank.length; i++) {
            require(
                isUserParticipatedBattle[_battleId][_rank[i]],
                "user unauthorized"
            );
            rewardOfPlayers[_rank[i]] += _bonusPrizePool
                .mul(bonusPercent[i])
                .div(1000);
        }
    }

    /**
     * @dev - To claim the single battle reward.
     * @param _battleId - Battle id for which rewards to be claimed.
     */
   function ClaimBattleReward(
        uint256 _battleId
    ) external nonReentrant Claimable(_battleId) {
        uint256 reward;

        require(rewardsEveryBattle[_battleId][msg.sender] > 0, "You may have already claimed or not entered");

        reward = rewardsEveryBattle[_battleId][msg.sender];
        commissionRewardTrackerContract.claimBattleReward(msg.sender,_battleId,reward);
        
        tokenManagerContract.makeTransferTo(msg.sender,reward,"BattleReward");

        emit _ClaimedReward(_battleId, msg.sender, reward);
        
        rewardsEveryBattle[_battleId][msg.sender] = 0;
    }

    /**
     * @dev - To claim the all battle rewards in single transaction.
     * @param _battleIds - List of battle ids for which rewards to be claimed.
     * 
     */
   function ClaimAllBattleReward(
        uint256[] memory _battleIds
    ) external nonReentrant {

        commissionRewardTrackerContract.claimAllBattleReward(msg.sender,_battleIds);
        
        uint256 length = _battleIds.length;
        
        for(uint256 i=0; i<length; i++){
            
            uint256 _battleId = _battleIds[i];
            rewardsEveryBattle[_battleId][msg.sender] = 0;
        }
    }



    /// *_palyer can claim bonus and create battle
    function AddVerifiedPlayer(address _player) external onlyOwner {
        isVerifiedPlayer[_player] = true;
    }

    function RemoveVerifiedPlayer(address _player) external onlyOwner {
        isVerifiedPlayer[_player] = false;
    }

    function SetBillionsNftAddress(address _addr) external onlyOwner {
        billionsNftAddress = _addr;
    }

    function SetScalarNftAddress(address _addr) external onlyOwner {
        scalarNftAddress = _addr;
    }

    function SetMarketplaceAddress(address _addr) external onlyOwner {
        marketplaceAddress = _addr;
    }

    /// get all players information in *_battleId game
    /// return arrays of player address and player infos
    function GetPlayersInBattle(
        uint256 _battleId
    )
        external
        view
        returns (address[] memory addrs, PlayerInfo[] memory infos)
    {
        addrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = addrs.length;
        infos = new PlayerInfo[](playerCount);

        mapping(address => PlayerInfo)
            storage dumpPlayerInfo = enteredPlayerInfos[_battleId];

        for (uint256 i = 0; i < playerCount; i++) {
            infos[i] = dumpPlayerInfo[addrs[i]];
        }
    }

    /// get player information with *_address from *_battleId game
    function GetPlayer(
        uint256 _battleId,
        address _address
    ) external view returns (PlayerInfo memory) {
        return enteredPlayerInfos[_battleId][_address];
    }

    /// get total number of palyers in *_battleId game
    function GetPlayerCountInBattle(
        uint256 _battleId
    ) external view returns (uint256) {
        return enteredPlayerAddress[_battleId].length;
    }

    /// get array of reward that can be claimed in *_battleId game
    function GetRewardsInBattle(
        uint256 _battleId
    ) external view returns (address[] memory, uint256[] memory) {
        address[] memory dumpAddrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = dumpAddrs.length;

        address[] memory addrs = new address[]((playerCount * 45) / 100 + 1);
        uint256[] memory rewards = new uint256[]((playerCount * 45) / 100 + 1);

        mapping(address => uint256) storage dumpRewards = rewardsEveryBattle[
            _battleId
        ];

        uint256 idx = 0;
        for (uint256 i = 0; i < playerCount; i++) {
            if (dumpRewards[dumpAddrs[i]] == 0) {
                continue;
            }

            addrs[idx] = dumpAddrs[i];
            rewards[idx] = dumpRewards[dumpAddrs[i]];
            idx += 1;
        }

        return (addrs, rewards);
    }

    /// get amount of reward that *_userAddress can be claimed in *_battleId game
    function GetPlayerReward(
        uint256 _battleId,
        address _userAddress
    ) external view returns (uint256 claimableAmount) {
        claimableAmount = rewardsEveryBattle[_battleId][_userAddress];
    }

    function GetBattle(
        uint256 _battleId
    ) external view returns (BattleInfo memory) {
        return battles[_battleId];
    }

    /// withdraw fund when someone sent other token in my wallet
    function withdrawFund(
        address _addr,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        IERC20 otherToken = IERC20(_addr);
        otherToken.transfer(msg.sender, _amount);
        return true;
    }

    function setRewardPercent(uint256[] memory ranks) external onlyOwner {
        require(ranks.length == 4, "");
        uint256 sum = 0;
        for (uint256 i = 0; i < 4; i++) {
            sum += ranks[i];
        }

        require(sum == 1000);

        for (uint256 i = 0; i < 4; i++) {
            rewardPercent[i] = ranks[i];
        }
    }

    function setBonusPercent(uint256[] memory ranks) external onlyOwner {
        require(ranks.length == 5, "");
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += ranks[i];
        }

        require(sum == 1000);

        for (uint256 i = 0; i < 5; i++) {
            bonusPercent[i] = ranks[i];
        }
    }

    function setRakePercent(uint256 rake) external onlyOwner {
        require(rake < 100);
        require(rake > leaderBonus);

        rakePercent = rake;
    }

    function setLeaderBonus(uint256 leader) external onlyOwner {
        require(leader < 100);
        require(rakePercent > leader);

        leaderBonus = leader;
    }

    function getIsUserParticipated(
        uint256 _battleId,
        address _user
    ) public view returns (bool) {
        return isUserParticipatedBattle[_battleId][_user];
    }

    /**
     * @dev - Adding top up for the battle prize pool by Admin
     * @param _battleId - Id of the battle on which the top has to be made
     * @param _topUpPrize - the amount to be added as top up
     */
    function topUpBattlePrizePool(uint256 _battleId, uint256 _topUpPrize) external onlyOwner{
        require(battles[_battleId].battleId != 0 ,"Invalid Battle id");
        battles[_battleId].extraRewards = _topUpPrize;
        emit _TopUpBattlePrize(_battleId,_topUpPrize,block.timestamp);
    }
    
    /**
     * @dev - Getting top up prize for the battle by Admin
     * @param _battleId - Id of the battle for which the topup prize has to be returned
     */
    function getTopUpPrizeForBattle(uint256 _battleId) external view onlyOwner returns(uint256){
        require(battles[_battleId].battleId != 0 ,"Invalid Battle id");
        return battles[_battleId].extraRewards;
    }
    
    /**
     * @dev - Setting commission for the battle by Admin
     * @param _newCommission - New commission for the battle to be deducted.
     */
    function setNewBattlePrizeCommission(uint256 _newCommission) external onlyOwner{
        uint256 oldCommission = BATTLE_PRIZE_COMMISSION;
        BATTLE_PRIZE_COMMISSION = _newCommission;

        emit _UpdateBattleCommission(oldCommission,_newCommission,block.timestamp);
    }
    
    /**
     * @dev - Getting commission for the battle by Admin
     * @return - Returns the commisison set for the battle.
     */
    function getBattlePrizeCommission() external view onlyOwner returns(uint256){
        return BATTLE_PRIZE_COMMISSION;
    }
    /**
     * @dev - Update the contract address by Admin
     */
    function setCommissionRewardTrackerAddress(address _newAddress) external onlyOwner{
        commissionRewardTrackerContract = CommissionRewardsTracker(_newAddress);
    }
}