// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;             // POLYGON network max=0.8.19

struct  TNft
{
    uint        mintId;
    uint        claimId;
    uint        inPlatformId;
    uint        merchantId;
    address     fromWallet;
    address     toWallet;
    uint        payAmount;
    string      merchantArticleRef;
    string      articleTitle;
    uint        payTokenIndex;
    string      method;
}

//==============================================================================
interface iERC20
{
    function    balanceOf(address guy)                              external view   returns (uint);
    function     transfer(address dst, uint amount)                 external        returns (bool);
    function transferFrom(address src, address dst, uint amount)    external        returns (bool);
}
//==============================================================================
interface IERC165
{
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
//==============================================================================
interface IERC721 is IERC165
{
    event   Transfer(      address indexed from,  address indexed to,       uint  indexed tokenId);
    event   Approval(      address indexed owner, address indexed approved, uint  indexed tokenId);
    event   ApprovalForAll(address indexed owner, address indexed operator, bool          approved);

    function balanceOf(        address owner)                               external view returns (uint balance);
    function ownerOf(          uint tokenId)                                external view returns (address owner);
    function safeTransferFrom( address from,     address to, uint tokenId)  external;
    function transferFrom(     address from,     address to, uint tokenId)  external;
    function approve(          address to,       uint tokenId)              external;
    function getApproved(      uint tokenId)                                external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved)            external;
    function isApprovedForAll( address owner,    address operator)          external view returns (bool);
    function safeTransferFrom( address from,     address to, uint tokenId, bytes calldata data) external;
}
//==============================================================================
contract ERC165 is IERC165
{
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool)
    {
        return (interfaceId == type(IERC165).interfaceId);
    }
}
//==============================================================================
interface IERC721Metadata is IERC721
{
    function name()                     external view returns (string memory);
    function symbol()                   external view returns (string memory);
    function tokenURI(uint tokenId)     external view returns (string memory);
}
//==============================================================================
interface IERC721Receiver
{
    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns (bytes4);
}
//==============================================================================
library Strings
{
    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint value) internal pure returns (string memory)
    {
        if (value==0)       return "0";
   
        uint temp = value;
        uint digits;
   
        while (temp!=0)
        {
            digits++;
            temp /= 10;
        }
       
        bytes memory buffer = new bytes(digits);
       
        while (value!=0)
        {
            digits        -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value         /= 10;
        }
       
        return string(buffer);
    }
}
//==============================================================================
library Address
{
    function isContract(address account) internal view returns (bool)
    {
        uint size;
       
        assembly { size := extcodesize(account) }   // solhint-disable-next-line no-inline-assembly
        return size > 0;
    }
    //---------------------------------------------------------------------
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory)
    {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    //---------------------------------------------------------------------
    function functionCallWithValue(
        address         target,
        bytes memory    data,
        uint256         value,
        string memory   errorMessage)
            internal
            returns (bytes memory)
    {
        require(address(this).balance >= value, "fCWV err");//"Address: insufficient balance for call");
   
        (bool success, bytes memory returndata) = target.call{value: value}(data);
   
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    //---------------------------------------------------------------------
    function verifyCallResultFromTarget(
        address         target,
        bool            success,
        bytes memory    returndata,
        string memory   errorMessage)
            internal
            view
            returns (bytes memory)
    {
        if (success)
        {
            if (returndata.length == 0)
            {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "vCRFT err");//Address: call to non-contract");
            }
           
            return returndata;
        }
        else
        {
            _revert(returndata, errorMessage);
        }
    }
    //---------------------------------------------------------------------
    function _revert(bytes memory returndata, string memory errorMessage) private pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0)
        {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        }
        else
        {
            revert(errorMessage);
        }
    }
}
//==============================================================================
contract Context
{
    function _msgSender() internal view virtual returns (address)
    {
        return msg.sender;
    }
    //----------------------------------------------------------------
    function _msgData() internal view virtual returns (bytes calldata)
    {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
//------------------------------------------------------------------------------
contract Ownable is Context
{
    address private _owner;

    event   OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()
    {
        address msgSender = _msgSender();
                   _owner = msgSender;
                   
        emit OwnershipTransferred(address(0), msgSender);
    }
   
    function owner() public view virtual returns (address)
    {
        return _owner;
    }
   
    modifier onlyOwner()
    {
        require(owner() == _msgSender(),    "Not owner");
        _;
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner
    {
        require(newOwner != address(0), "Bad addr");
       
        emit OwnershipTransferred(_owner, newOwner);
       
        _owner = newOwner;
    }
}
//==============================================================================
contract ReentrancyGuard
{
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED     = 2;

    uint private _status;

    constructor()
    {      
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant()         // Prevents a contract from calling itself, directly or indirectly.
    {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");    // On the first call to nonReentrant, _notEntered will be true
        _status = _ENTERED;                                                 // Any calls to nonReentrant after this point will fail
        _;
        _status = _NOT_ENTERED;                                             // By storing the original value once again, a refund is triggered (see // https://eips.ethereum.org/EIPS/eip-2200)
    }
}//=============================================================================
contract ERC721 is  ERC165, IERC721, IERC721Metadata, Ownable, ReentrancyGuard
{
    using Address for address;
    using Strings for uint;

    string private _name;   // Token name
    string private _symbol; // Token symbol
    string private _baseUri;

    mapping(uint    => address)                  internal _owners;              // Mapping from token ID to owner address
    mapping(address => uint)                     internal _balances;            // Mapping owner address to token count
    mapping(uint    => address)                  private  _tokenApprovals;      // Mapping from token ID to approved address
    mapping(address => mapping(address => bool)) private  _operatorApprovals;   // Mapping from owner to operator approvals
   
    constructor(string memory name_, string memory symbol_)
    {
        _name   = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool)
    {
        return  interfaceId == type(IERC721).interfaceId         ||
                interfaceId == type(IERC721Metadata).interfaceId ||
                super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint)
    {
        require(owner != address(0), "e721 0");//"ERC721: no ZERO addr");
       
        return _balances[owner];
    }
    function ownerOf(uint tokenId) public view virtual override returns (address)
    {
        address owner = _owners[tokenId];
        require(owner != address(0), "e721: oO 0");//ERC721: no owner ZERO");
        return owner;
    }
    function name() public view virtual override returns (string memory)
    {
        return _name;
    }
    function symbol() public view virtual override returns (string memory)
    {
        return _symbol;
    }
    function setBaseUri(string memory baseUri) external onlyOwner 
    {
        _baseUri = baseUri;
    }
    function _baseURI() internal view virtual  returns (string memory) 
    {
        return _baseUri;
    }
    function tokenURI(uint tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "e721 bad tok");//ERC721Mt: unknown Token");

        string memory baseURI = _baseURI();
       
        return (bytes(baseURI).length>0) ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function approve(address to, uint tokenId) public virtual override
    {
        address owner = ERC721.ownerOf(tokenId);
   
        require(to!=owner, "e721 aproval e1");//ERC721: approval to current owner");
        require(_msgSender()==owner || ERC721.isApprovedForAll(owner, _msgSender()), "e721 approval e2");//ERC721: approve caller is not owner nor approved for all");

        _approve(to, tokenId);
    }
    function getApproved(uint tokenId) public view virtual override returns (address)
    {
        require(_exists(tokenId), "e721 approved e1");//ERC721: approved unknown token");

        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override
    {
        require(operator != _msgSender(), "e721 approve e2");//ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
   
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint tokenId) public virtual override
    {
        //----- solhint-disable-next-line max-line-length
       
        require(_isApprovedOrOwner(_msgSender(), tokenId), "e721 transf e1");//ERC721: transfer not owner nor approved");

        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint tokenId) public virtual override
    {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) public virtual override
    {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "e721 transf e2");//ERC721: transfer not owner nor approved");
       
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from, address to, uint tokenId, bytes memory _data) internal virtual
    {
        _transfer(from, to, tokenId);
   
        require(_checkOnERC721Received(from, to, tokenId, _data), "not e721");//Non ERC721 receiver");
    }
    function _exists(uint tokenId) internal view virtual returns (bool)
    {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns (bool)
    {
        require(_exists(tokenId), "e721 token e2");//ERC721: unknown token");
       
        address owner = ERC721.ownerOf(tokenId);
       
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint tokenId) internal virtual
    {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint tokenId, bytes memory _data) internal virtual
    {
        _mint(to, tokenId);
   
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "not e721 2");//Non ERC721 receiver");
    }
    function _mint(address to, uint tokenId) internal virtual
    {
        require(to != address(0),  "e721 mint 0");//ERC721: no ZERO mint");
        require(!_exists(tokenId), "e721 minted");//ERC721: already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to]   += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    function _batchMint(address to, uint[] memory tokenIds) internal virtual
    {
        require(to != address(0), "e721 mint2 0");//ERC721: no ZERO mint");
       
        _balances[to] += tokenIds.length;

        for (uint i=0; i < tokenIds.length; i++)
        {
            require(!_exists(tokenIds[i]), "e721 minted 2");//ERC721: already minted");

            _beforeTokenTransfer(address(0), to, tokenIds[i]);

            _owners[tokenIds[i]] = to;

            emit Transfer(address(0), to, tokenIds[i]);
        }
    }
    function _burn(uint tokenId) internal virtual
    {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);      // Clear approvals

        _balances[owner] -= 1;

        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from, address to, uint tokenId) internal virtual
    {
        require(ERC721.ownerOf(tokenId)==from,  "ERC721: Not owner");
        require(to != address(0),               "e721 0 err");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);      // Clear approvals from the previous owner

        _balances[from] -= 1;
        _balances[to]   += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint tokenId) internal virtual
    {
        _tokenApprovals[tokenId] = to;
   
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _checkOnERC721Received(address from,address to,uint tokenId,bytes memory _data) private returns (bool)
    {
        if (to.isContract())
        {
            try
           
                IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
           
            returns (bytes4 retval)
            {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            }
            catch (bytes memory reason)
            {
                if (reason.length==0)
                {
                    revert("Non ERC721 receiver");
                }
                else
                {
                    assembly { revert(add(32, reason), mload(reason)) }     //// solhint-disable-next-line no-inline-assembly
                }
            }
        }
        else
        {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual
    {
        //
    }
}
//==============================================================================
contract    AMintingContract     is  ERC721
{
    using Address for address;
    using Strings for uint;

    address[5]  private  mintingCurrencyTokens = 
    [ 
        0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174,         // USDC.e
        0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359,         // USDC (new)
        0xc2132D05D31c914a87C6611C10748AEb04B58e8F,         // USDT
        0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE,         // DAI
        address(0x0)                    
    ];

    string                  private     baseURI = "";
    address                 public      nspContract = 0xf4Dd07E443913091d3465d80DAca1645F5f8a3d5;
    mapping(uint => bool)   private     isMintedIds;
    address                 public      officialClaimer;

    constructor() ERC721("NoSTPV9_nft", "NSTPN4") 
    {
        if (block.chainid==80002)
        {
            nspContract = 0xFD14dCf5Fa821A97EbD801b7756c6Bd26A354BD9;

            mintingCurrencyTokens = 
            [ 
                0x2134813763f70912B6BF1E87467FDDdF3ad7fFfa,         // SDC Token              
                0x23D638106387c8188F6e3ae675d4362228eB2942,         // EUROC Token
                0xb035f6f6d0F03cb7aC4A031A1D3211Ef8FBC3D9A,         // xUSDC Token
                0x23D638106387c8188F6e3ae675d4362228eB2942,         // EUROC Token
                address(0x0) 
            ];        
        }

        officialClaimer = msg.sender;
    }

    uint    public      articleNftIndex = 0;
    uint    public      claimNftIndex   = 0;

    mapping(uint => uint)   private     nftClaimedIds;
    TNft[]                  private     nftList;
    TNft[]                  private     claimedNftList;

    mapping(uint => uint)   private     claimedIdByPlatformIds;
    mapping(uint => uint)   private     claimedIdByMintIds;
    mapping(uint => uint)   private     mintIdIdPlatformIds;
    mapping(uint => uint)   private     mintIdByClaimedIds;
    mapping(uint => uint)   private     platformIdByMintIds;
    mapping(uint => uint)   private     platformIdByClaimedIds;

    //-----

    event   Mint(TNft);
    event   TransferableMint(TNft);
    event   ClaimNft(TNft);
    event   SetNspContract(address oldContract, address newContract);
    event   Received(address, uint);
    event   ChangePayToken(uint index, address newErc20Token);
    event   SetOfficialClaimer(address newClaier, address oldClaimer);


    //---------------------------------------------------------------------------
    receive() external payable
    {
        emit Received(msg.sender, msg.value);               // Accept MATIC
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    receivePayment(address erc20Token, uint amount, string memory errorMsg) internal
    {
        bytes memory rt = address(iERC20(erc20Token)).functionCall
        (
            abi.encodeWithSelector
            (
                iERC20(erc20Token).transferFrom.selector,
                msg.sender,
                address(this),
                amount
            )
            ,
            errorMsg
        );

        if (rt.length > 0)
        {
            require(abi.decode(rt, (bool)), "SafeERC20: receivePayment FAILED");
        }
    }
    //---------------------------------------------------------------------------
    function    transferPayment(address erc20Token, address to, uint amount, string memory errorMsg) internal
    {
        bytes memory rt = address(iERC20(erc20Token)).functionCall
        (
            abi.encodeWithSelector
            (
                iERC20(erc20Token).transfer.selector,
                to,
                amount
            )
            ,
            errorMsg
        );

        if (rt.length > 0)
        {
            require(abi.decode(rt, (bool)), "TP Failed");
        }
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    mint(   uint            merchantId,
                        address         toWallet,            // buyWallet & msg.sender can be different (like if using crossMint service)
                        uint            payAmount,
                        string memory   merchantArticleRef,
                        string memory   articleTitle,
                        uint            inPlatformId,
                        uint            payTokenIndex)
                    external
                    nonReentrant
    {
        require(isMintedIds[inPlatformId]==false,  "inPlatformId known");
        require(nspContract!=address(0x0),         "Zero error");

        address erc20Token = mintingCurrencyTokens[payTokenIndex];

        require(iERC20(erc20Token).balanceOf(msg.sender)>=payAmount, "Balance low");

        transferPayment(erc20Token, nspContract, payAmount, "ERC20 Transfer Error");

        ++articleNftIndex;
        _mint(toWallet, articleNftIndex);

        isMintedIds[inPlatformId] = true;      // used!

        TNft memory  NFT = TNft
        (
            articleNftIndex,
            0,
            inPlatformId,
            merchantId,
            msg.sender, 
            toWallet,
            payAmount,
            merchantArticleRef,
            articleTitle,
            payTokenIndex,
            "mint"
        );

        mintIdIdPlatformIds[inPlatformId]    = articleNftIndex;
        platformIdByMintIds[articleNftIndex] = inPlatformId;

        nftList.push(NFT);

        emit Mint(NFT);
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    transferableMint(   uint            merchantId,
                        address         toWallet,
                        uint            payAmount,
                        string memory   merchantArticleRef,
                        string memory   articleTitle,
                        uint            inPlatformId,
                        uint            payTokenIndex)
                    external
                    nonReentrant
    {
        require(isMintedIds[inPlatformId]==false, "inPlatformId known");
        require(nspContract!=address(0x0),         "Zero error");

        address erc20Token = mintingCurrencyTokens[payTokenIndex];

        require(iERC20(erc20Token).balanceOf(msg.sender)>=payAmount, "Balance low");

        receivePayment( erc20Token,              payAmount, "receivePayment error");
        transferPayment(erc20Token, nspContract, payAmount, "transferPayment error");

        ++articleNftIndex;
        _mint(toWallet, articleNftIndex);

        isMintedIds[inPlatformId] = true;      // used!

        TNft memory  NFT = TNft
        (
            articleNftIndex,
            0,
            inPlatformId,
            merchantId,
            msg.sender, 
            toWallet,
            payAmount,
            merchantArticleRef,
            articleTitle,
            payTokenIndex,
            "transferableMint"
        );

        mintIdIdPlatformIds[inPlatformId]    = articleNftIndex;
        platformIdByMintIds[articleNftIndex] = inPlatformId;

        nftList.push(NFT);

        emit TransferableMint(NFT);
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    claimNft(uint           merchantId,
                        address         toWallet,            // buyWallet & msg.sender can be different (like if using crossMint service)
                        uint            payAmount,
                        string memory   merchantArticleRef,
                        string memory   articleTitle,
                        uint            inPlatformId,
                        uint            payTokenIndex)
                    external
                    nonReentrant
    {
        require(claimedIdByPlatformIds[inPlatformId]==0, "inPlatform Id known");
        require(msg.sender==officialClaimer,             "Invalid caller");

        ++articleNftIndex;
        _mint(toWallet, articleNftIndex);

        ++claimNftIndex;

        TNft memory  NFT = TNft
        (
            articleNftIndex,
            claimNftIndex,
            inPlatformId,
            merchantId,
            msg.sender, 
            toWallet,
            payAmount,
            merchantArticleRef,
            articleTitle,
            payTokenIndex,
            "claimNft"
        );

        claimedIdByPlatformIds[inPlatformId]    = claimNftIndex;
        claimedIdByMintIds[articleNftIndex]     = claimNftIndex;
        mintIdIdPlatformIds[inPlatformId]       = articleNftIndex;
        mintIdByClaimedIds[claimNftIndex]       = articleNftIndex;
        platformIdByMintIds[articleNftIndex]    = inPlatformId;
        platformIdByClaimedIds[articleNftIndex] = inPlatformId;

        nftList.push(NFT);
        claimedNftList.push(NFT);

        emit ClaimNft(NFT);
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    getClaimedNftIdByPlatformId(uint id) external view returns(uint)    { return claimedIdByPlatformIds[id];    }
    function    getClaimedNftIdByMintId(    uint id) external view returns(uint)    { return claimedIdByMintIds[id];        }
    function    getMintIdIdPlatformIds(     uint id) external view returns(uint)    { return mintIdIdPlatformIds[id];       }
    function    getMintIdByClaimedIds(      uint id) external view returns(uint)    { return mintIdByClaimedIds[id];        }
    function    getPlatformIdByMintIds(     uint id) external view returns(uint)    { return platformIdByMintIds[id];       }
    function    getPlatformIdByClaimedIds(  uint id) external view returns(uint)    { return platformIdByClaimedIds[id];    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    getNftCount() external view returns(uint)
    {
        return nftList.length;
    }
    //---------------------------------------------------------------------------
    function    getClaimedNftCount() external view returns(uint)
    {
        return claimedNftList.length;
    }
    //---------------------------------------------------------------------------
    function    getNfts(uint from, uint to) external view returns (TNft[] memory)
    {
        uint count = nftList.length;

        require(from<count, "Invalid From");
        require(to<count,   "Invlid To");

        if (from>to)
        {
            uint v = from;
            from   = to;
            to     = v;
        }

      unchecked
      {
        uint nToExtract = (to - from) + 1;

        TNft[] memory list = new TNft[](nToExtract);

        uint g = 0;

        for (uint i = from; i <= to; i++)
        {
            list[g] = nftList[i];
            g++;
        }

        return list;
      }    
    }
    //---------------------------------------------------------------------------
    function    getClaimedNfts(uint from, uint to) external view returns (TNft[] memory)
    {
        uint count = claimedNftList.length;

        require(from<count, "Invalid From");
        require(to<count,   "Invlid To");

        if (from>to)
        {
            uint v = from;
            from   = to;
            to     = v;
        }

      unchecked
      {
        uint nToExtract = (to - from) + 1;

        TNft[] memory list = new TNft[](nToExtract);

        uint g = 0;

        for (uint i = from; i <= to; i++)
        {
            list[g] = claimedNftList[i];
            g++;
        }

        return list;
      }    
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function    setNspContract(address newContract) external onlyOwner
    {
        address oldContract = nspContract;
                nspContract = newContract;

        emit SetNspContract(oldContract, newContract);
    }
    //---------------------------------------------------------------------------
    function    changePayToken(uint index, address newErc20Token) external onlyOwner
    {
        require(newErc20Token!=address(0x0), "Bad 0a");

        mintingCurrencyTokens[index] = newErc20Token;

        emit ChangePayToken(index, newErc20Token);
    }
    //---------------------------------------------------------------------------
    function    getPayTokenById(uint index) external view returns(address)
    {
        return (mintingCurrencyTokens[index]);
    }
    //---------------------------------------------------------------------------
    function    setOfficialClaimer(address newClaimer) external
    {
        require(newClaimer!=address(0x0), "Invalid address");

        address oldClaimer      = officialClaimer;
                officialClaimer = newClaimer;

        emit SetOfficialClaimer(newClaimer, oldClaimer);
    }
    //---------------------------------------------------------------------------
    function withdrawMatic(address payable to, uint amount) external onlyOwner 
    {
        require(to != address(0), "Invalid address");
        require(amount <= address(this).balance, "Insufficient balance");
    
        (bool success, ) = to.call{value: amount}("");
        require(success, "MATIC transfer failed");
    }
}