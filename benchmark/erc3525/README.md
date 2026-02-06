raw_1.sol is the original ERC3525
made_*.sol are randomly injected with ERC violations:

## made_1.sol
- [interface] Remove "transferFrom(3) uint256"
- [emit] Remove "TransferValue event emission in transferFrom(3)"
- [throw] Remove " MUST revert if `_fromTokenId` is zero in transferFrom(3)"
## made_2.sol
- [interface] Remove "balanceOf"
- [emit] Remove "ApprovalValue event emission in approve"
- [throw] Remove "MUST revert unless caller xxx in approve"
## made_3.sol
- [interface] Remove "slotOf"
- [emit] Remove "SlotChanged in burn"
- [emit] Remove "TransferValue in transferFrom(3)"
## made_4.sol
- [interface] Remove "transferFrom"
- [interface] Remove "allowance"
- [throw] Remove "MUST revert unless caller xxx in approve"
## made_5.sol
- [throw] Remove "MUST revert if `_fromTokenId` or `_toTokenId` is zero token id or does not exist in transferFrom(3)"
- [emit] Remove "ApprovalValue event emission in approve"
- [throw] Remove "MUST revert if `_value` exceeds the balance of `_fromTokenId` or its allowance to the in transferFrom(3)"
## made_6.sol
- [interface] Remove "approve"
- [interface] Remove "valueDecimals"
- [emit] Remove "SlotChanged in burn"
## made_7.sol
- [interface] Remove "transferFrom(3)"
- [throw] Remove " MUST revert if `_to` is zero address in transferFrom(3) uint256"
- [throw] Remove " MUST revert unless caller in approve"
## made_8.sol
- [throw] Remove "MUST revert if `_fromTokenId` is zero token id or does not exist in transferFrom(3) uint256"
- [emit] Remove "TransferValue in transferFrom(3)"
- [throw] Remove "Caller MUST be the current owner in transferFrom(3)"
## made_9.sol
- [emit] Remove "SlotChanged in burn"
- [emit] Remove ""TransferValue in transferFrom(3)""
- [throw] Remove "Caller MUST be the current owner ... in transferFrom(3)"
## made_10.sol
- [emit] Remove "ApprovalValue event emission in approve"
- [emit] Remove "SlotChanged in burn"
- [interface] Remove "allowance"