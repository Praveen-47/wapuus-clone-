// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @replacement
//  finnPrice  => finnPrice
// finnRenamePrice => finnRenamePrice
// maxFinnPurchase => maxFinnPurchase
// MAX_FINNS => MAX_FINNS
// finnNames => finnNames
// finnNameChange => finnNameChange
// reserveFinn => reserveFinn
// finnReserve => finnReserve



pragma solidity ^0.8.0;

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}

// Wapuu is the (un)official mascot of WordPress. By promoting Finns, we bring awareness to WordPress. Wapuu is also making the WordPress community approachable and inviting.
// Wapuu Team: UglyRobot, LLC

contract Finn_ERC721 is ERC721Enumerable, Ownable {

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    /*
     * bytes4(keccak256('getRoyalties(LibAsset.AssetType)')) == 0x44c74bcc
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0x44c74bcc;

    string public FINN_PROVENANCE = ""; // IPFS URL WILL BE ADDED WHEN Finns ARE ALL SOLD OUT
    
    string public LICENSE_TEXT = "GPLv2"; // IT IS WHAT IT SAYS
    
    string private _baseTokenURI = "https://hof.mypinata.cloud/ipfs/QmbY4Wu9K9ZRqYPDK9V3nPeCu3zN2Zs2cGUTkWyvxKV26J/";

    bool licenseLocked = false; // TEAM CAN'T EDIT THE LICENSE AFTER THIS GETS TRUE

    uint256 public finnPrice = 20000000000000000; // 0.02 ETH
    uint256 public finnRenamePrice = 10000000000000000; // 0.01 ETH
    uint96 public royaltyBPS = 600; // 6% royalty for Rarible/Mintable

    uint public constant maxFinnPurchase = 20;

    uint256 public constant MAX_FINNS = 2222;

    bool public saleIsActive = false;
    
    mapping(uint => string) public finnNames;
    
    // Reserve 50 Finns for team - Giveaways/Prizes etc
    uint public finnReserve = 50;
    
    event finnNameChange(address _by, uint _tokenId, string _name);
    
    event licenseisLocked(string _licenseText);

    constructor() ERC721("Finns", "WAPUU") { }
    
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
    
    function reserveFinn(address _to, uint256 _reserveAmount) public onlyOwner {        
        uint supply = totalSupply();
        require(_reserveAmount > 0 && _reserveAmount <= finnReserve, "No rsrv");
        for (uint i = 0; i < _reserveAmount; i++) {
            _safeMint(_to, supply + i);
        }
        finnReserve = finnReserve - _reserveAmount;
    }

    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        FINN_PROVENANCE = provenanceHash;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }
    
    function tokensOfOwner(address _owner) external view returns(uint256[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }
    
    // Returns the license for tokens
    function tokenLicense(uint _id) public view returns(string memory) {
        require(_id < totalSupply(), "Invld Tkn");
        return LICENSE_TEXT;
    }
    
    // Locks the license to prevent further changes 
    function lockLicense() public onlyOwner {
        licenseLocked =  true;
        emit licenseisLocked(LICENSE_TEXT);
    }
    
    // Change the license
    function changeLicense(string memory _license) public onlyOwner {
        require(licenseLocked == false, "Alrdy lckd");
        LICENSE_TEXT = _license;
    }
    
    // Change the mintPrice
    function setMintPrice(uint256 newPrice) public onlyOwner {
        require(newPrice != finnPrice, "Not new");
        finnPrice = newPrice;
    }
    
    // Change the finnRenamePrice
    function setRenamePrice(uint256 newPrice) public onlyOwner {
        require(newPrice != finnRenamePrice, "Not new");
        finnRenamePrice = newPrice;
    }
    
    // Change the royaltyBPS
    function setRoyaltyBPS(uint96 newRoyaltyBPS) public onlyOwner {
        require(newRoyaltyBPS != royaltyBPS, "Not new");
        royaltyBPS = newRoyaltyBPS;
    }

    function mintFinns(uint numberOfTokens) public payable {
        require(saleIsActive, "Sale Inactv");
        require(numberOfTokens > 0 && numberOfTokens <= maxFinnPurchase, "Max 20");
        require(totalSupply() + numberOfTokens <= MAX_FINNS, "Excds max sply");
        require(msg.value >= finnPrice * numberOfTokens, "Chk prce");
        require(msg.value == finnPrice * numberOfTokens, "Chk prce");
        
        for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < MAX_FINNS) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }
     
    function changeFinnName(uint _tokenId, string memory _name) public payable {
        require(ownerOf(_tokenId) == msg.sender, "Prmsns Err");
        require(sha256(bytes(_name)) != sha256(bytes(finnNames[_tokenId])), "Not new");
        require(msg.value >= finnRenamePrice, "Chk prce");
        require(msg.value == finnRenamePrice, "Chk prce");
        finnNames[_tokenId] = _name;
        
        emit finnNameChange(msg.sender, _tokenId, _name);
    }
    
    function viewWapuuName(uint _tokenId) public view returns( string memory ){
        require( _tokenId < totalSupply(), "Invld Tkn" );
        return finnNames[_tokenId];
    }
    
    // GET ALL Finns OF A WALLET AS AN ARRAY OF STRINGS. WOULD BE BETTER MAYBE IF IT RETURNED A STRUCT WITH ID-NAME MATCH
    function finnNamesOfOwner(address _owner) external view returns(string[] memory ) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new string[](0);
        } else {
            string[] memory result = new string[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = finnNames[ tokenOfOwnerByIndex(_owner, index) ] ;
            }
            return result;
        }
    }

    //Rarible royalty interface new
    function getRaribleV2Royalties(uint256 id) external view returns (LibPart.Part[] memory) {
         LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = royaltyBPS;
        _royalties[0].account = payable(owner());
        return _royalties;
    }

    //Mintable/ERC2981 royalty handler
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {
       return (owner(), (_salePrice * royaltyBPS)/10000);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable) returns (bool) {
        if(interfaceId == _INTERFACE_ID_ROYALTIES) {
            return true;
        }
        if(interfaceId == _INTERFACE_ID_ERC2981) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }
}