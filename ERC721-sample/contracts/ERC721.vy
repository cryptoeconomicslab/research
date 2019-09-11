
contract ERC721:
  def transferFrom(_from: address, _to: address, _tokenId: uint256): modifying

  def safeTransferFrom(_from: address, _to: address, _tokenId: uint256): modifying 

#data stored tokenContractId uniqueTokenId and address in a map 
tokenIdToAddress: public(map(uint256, map(uint256, address)))

# @dev deposit 
@public
def depositERC721(
  tokenAddress: address, #contract adress of the deposited NFT
  tokenContractId: uint256, #which NFT defined by id
  uniqueTokenId: uint256 #which unique token defined by id 
):
  depositor: address = msg.sender 
  ERC721(tokenAddress).transferFrom(depositor, self, tokenContractId)
  self.tokenIdToAddress[tokenContractId][uniqueTokenId] = depositor

#@deve refer to the owner of deposited unique tokens   
@public
@constant
def ownerOf(tokenContractId: uint256, uniqueTokenId: uint256) -> address:
  return self.tokenIdToAddress[tokenContractId][uniqueTokenId]


# transfer 
@public
def transferERC721(
  tokenAddress: address, #contract adress of the deposited NFT
  tokenContractId: uint256, #which NFT defined by contract address 
  uniqueTokenId: uint256, #which unique token defined by id 
  recepient: address
):
  sender: address = msg.sender 
  ERC721(tokenAddress).transferFrom(sender, recepient, tokenContractId)
  self.tokenIdToAddress[tokenContractId][uniqueTokenId] = recepient
  