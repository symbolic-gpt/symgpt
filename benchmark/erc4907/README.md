1.sol:  https://github.com/rugpullindex/ERC4907
2.sol:  https://github.com/masaun/rental-tenant-space-protocol-using-ERC4907-NFT
3.sol:  https://github.com/emojidao/ERC4907Box
4.sol:  https://github.com/emojidao/ERC4907Factory
5.sol:  https://github.com/babamovandrej/ERC4907_Implementation_Contracts
6.sol:  https://github.com/abhishekb740/RentVault
7.sol:  https://github.com/0fatih/erc4907-implementation
8.sol:  https://github.com/sidarth16/Rentable-NFTs
9.sol:  https://github.com/wuhuiping2024/ERC49070.git
10.sol: https://github.com/ltmuyuan/ERC4907


All files are different:
find benchmark/erc4907 -type f -exec md5sum {} + | sort | uniq -w32 -dD

Original comes with violation:
6.sol: 
- setUser: Throws if `tokenId` is not valid NFT


Injected:
1.sol:
- Remove UpdateUser event emission from setUser function
- Remove function userExpires 
- Remove event UpdateUser

2.sol:
- Remove function userExpires 
- Remove event UpdateUser
- Remove function userOf

3.sol:
- Remove check for valid NFT at function setUser
- Remove function userOf
- Remove UpdateUser event emission from setUser function

4.sol:
- Remove function setUser
- Remove function userOf
- Remove function userExpires

5.sol:
- Remove check for valid NFT at function setUser
- Remove function userExpires
- Remove event UpdateUser

6.sol: Skip for containing original 

7.sol:
- Remove function setUser
_ Remove event UpdateUser
- Remove function userOf


8.sol:
- Remove check for valid NFT at function setUser
- Remove event UpdateUser
- Remove UpdateUser event emission from setUser function

9.sol:
- Remove function userExpires 
- Remove check for valid NFT at function setUser
- Remove event UpdateUser
- 
10.sol:
- Remove check for valid NFT at function setUser
- Remove function userExpires
- Remove UpdateUser event emission from setUser function