// SPDX-License-Identifier: SoftProDev

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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


contract RandomNumArray {
    uint randArrayFixedSize = 10;
    uint[] public randArray = new uint[](randArrayFixedSize);
    uint maxRandNumber = 9999999999;

    function generateRandomNumber() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % maxRandNumber;
    }

    function createRandomArray() public view returns (uint256[] memory){
        uint[] memory randomArray = new uint[](randArrayFixedSize);
        for(uint i = 0; i< randArrayFixedSize ; i++){
            randomArray[i] = uint(keccak256(abi.encodePacked(block.timestamp+i,block.difficulty,msg.sender))) % maxRandNumber;
            if (randomArray[i] == 0){
                randomArray[i] = uint(keccak256(abi.encodePacked(block.timestamp+i,block.difficulty,msg.sender))) % maxRandNumber;
            }           
        }
        return randomArray;
    }
    
    function generateRandomArray()public returns (uint256[] memory){
        uint[] memory temprandomArray = createRandomArray();
        for(uint i = 0; i< randArrayFixedSize ; i++){
            randArray[i] = temprandomArray[i];                      
        }
        return randArray;
    }
    
    function get(uint256 i) public view returns (uint256) {
        return randArray[i];
    }

    function getArr() public view returns (uint256[] memory) {
        return randArray;
    }

    function getLength() public view returns (uint) {
        return randArray.length;
    }
}
contract testEscrow is RandomNumArray, Ownable {
    struct EscrowStruct
    {    
        uint escrowID;
        address buyer;
        uint[] postedAssets;
        bool[] postedAssetsIsRedeemed;
        address[] sellerAddressArray;
        uint amount;
        uint redeemAmountPerNumber;
        uint createdDate;
        bool isActive;  
        uint escrowFee;         
    }

    struct SellerStruct
    {    
        uint escrowID;
        address seller;
        uint[] collectedAssets;
        uint createdDate;
        uint redeemedAmount; 
    }

    mapping(address => EscrowStruct[]) private buyerDatabase;
    mapping(address => SellerStruct[]) private sellerDatabase;

    EscrowStruct[] private escrowArray;
    SellerStruct[] private sellerArray;
    uint public escrowCount;
    uint private contractEscrowFee;
    uint private partyApercentage;
    uint private partyBpercentage;

    constructor(){
        escrowCount = 0;
        contractEscrowFee = 10;
        partyApercentage = 20;
        partyBpercentage = 80;
    }


    // Functions for OnlyOwner

    // Get Buyer Database By Address - Only Owner
    function getBuyerDataBaseByAddress(address _buyerAddress)public view onlyOwner returns(EscrowStruct[] memory){
        return buyerDatabase[_buyerAddress];
    }
    // Get Seller Database By Address - Only Owner
    function getSellerDataBaseByAddress(address _sellerAddress)public view onlyOwner returns(SellerStruct[] memory){
        return sellerDatabase[_sellerAddress];
    }
    // Get EscrowArray - Only Owner
    function getEscrowArray()public view onlyOwner returns(EscrowStruct[] memory){
        return escrowArray;
    }
    // Get EscrowArray - Only Owner
    function getSellerArray()public view onlyOwner returns(SellerStruct[] memory){
        return sellerArray;
    }
    // Get Escrow By ID
    function getEscrowByID(uint _escrowID)public view onlyOwner returns(EscrowStruct memory,bool){
        bool isExist = false;
        EscrowStruct memory escrow;
        for (uint i = 0; i < escrowArray.length; i++)
        {
            if (escrowArray[i].escrowID == _escrowID){
                escrow = escrowArray[i];
                isExist = true;
            }
        }
        return (escrow, isExist);
    }
    // Get Seller By Address
    function getSellerInfoByAddressAndEscrowID(address _sellerAddress,uint _escrowID) public view onlyOwner returns(SellerStruct memory, bool){
        bool isExist = false;
        SellerStruct memory sellerInfo;

        for (uint i = 0; i < sellerDatabase[_sellerAddress].length; i++)
        {
            if (sellerDatabase[_sellerAddress][i].escrowID == _escrowID){
                sellerInfo = sellerDatabase[_sellerAddress][i];
                isExist = true;
            }
        }
        return (sellerInfo, isExist);
    }

}