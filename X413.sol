// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title 4GIRL
 * @dev OpenSea Compatible NFT - Breaking Web2 413 Error Limits
 * 使用链上随机数，无需外部依赖
 */
contract 4GIRL is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIdCounter;
    
    // Configuration
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PER_WALLET = 20;
    bool public mintingEnabled = true;
    
    // NFT Types (5 designs matching your 1-5.png files)
    enum NFTType {
        GENESIS_BREAKER,    // 1.png - Rare
        CYBER_OVERFLOW,     // 2.png - Ultra Rare  
        PAYLOAD_PHOENIX,    // 3.png - Epic
        INFINITE_BUFFER,    // 4.png - Mythic
        WEB3_LIBERATION     // 5.png - Legendary
    }
    
    // Storage
    mapping(uint256 => NFTType) public tokenTypes;
    mapping(address => uint256) public mintedPerWallet;
    
    // GitHub Raw Content Base URI - 使用你的实际GitHub仓库
    string private constant BASE_URI = "https://raw.githubusercontent.com/talonmemancing-sys/4GIRLProtocol-/main/";
    
    mapping(NFTType => string) public typeImages;
    mapping(NFTType => string) public typeRarity;
    mapping(NFTType => string) public typeNames;
    
    // Events
    event NFTMinted(address indexed to, uint256 indexed tokenId, NFTType nftType);
    
    constructor() ERC721("4GIRL", "4GIRL") Ownable(msg.sender) {
        _tokenIdCounter.increment(); // Start from 1
        
        // 设置图片文件名 - 对应你的1-5.png
        typeImages[NFTType.GENESIS_BREAKER] = "1.png";
        typeImages[NFTType.CYBER_OVERFLOW] = "2.png";
        typeImages[NFTType.PAYLOAD_PHOENIX] = "3.png";
        typeImages[NFTType.INFINITE_BUFFER] = "4.png";
        typeImages[NFTType.WEB3_LIBERATION] = "5.png";
        
        // 设置稀有度
        typeRarity[NFTType.GENESIS_BREAKER] = "Rare";
        typeRarity[NFTType.CYBER_OVERFLOW] = "Ultra Rare";
        typeRarity[NFTType.PAYLOAD_PHOENIX] = "Epic";
        typeRarity[NFTType.INFINITE_BUFFER] = "Mythic";
        typeRarity[NFTType.WEB3_LIBERATION] = "Legendary";
        
        // 设置名称
        typeNames[NFTType.GENESIS_BREAKER] = "Genesis Breaker";
        typeNames[NFTType.CYBER_OVERFLOW] = "Cyber Overflow";
        typeNames[NFTType.PAYLOAD_PHOENIX] = "Payload Phoenix";
        typeNames[NFTType.INFINITE_BUFFER] = "Infinite Buffer";
        typeNames[NFTType.WEB3_LIBERATION] = "Web3 Liberation";
    }
    
    /**
     * @dev Public mint function with random NFT type
     */
    function mint() external returns (uint256) {
        require(mintingEnabled, "4GIRL: Minting disabled");
        require(totalSupply() < MAX_SUPPLY, "4GIRL: Max supply reached");
        require(mintedPerWallet[msg.sender] < MAX_PER_WALLET, "4GIRL: Max per wallet reached");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        // Generate pseudo-random number for NFT type
        uint256 randomValue = _getRandomNumber(tokenId);
        NFTType nftType = _determineRarity(randomValue);
        
        // Mint NFT
        _safeMint(msg.sender, tokenId);
        tokenTypes[tokenId] = nftType;
        mintedPerWallet[msg.sender]++;
        
        emit NFTMinted(msg.sender, tokenId, nftType);
        
        return tokenId;
    }
    
    /**
     * @dev Mint with specific type (only owner)
     */
    function mintSpecific(address to, uint256 nftTypeId) external onlyOwner returns (uint256) {
        require(totalSupply() < MAX_SUPPLY, "4GIRL: Max supply reached");
        require(nftTypeId <= uint256(NFTType.WEB3_LIBERATION), "4GIRL: Invalid NFT type");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        tokenTypes[tokenId] = NFTType(nftTypeId);
        
        emit NFTMinted(to, tokenId, NFTType(nftTypeId));
        
        return tokenId;
    }
    
    /**
     * @dev Batch mint for owner
     */
    function batchMint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "4GIRL: Would exceed max supply");
        
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            
            uint256 randomValue = _getRandomNumber(tokenId);
            NFTType nftType = _determineRarity(randomValue);
            
            _safeMint(to, tokenId);
            tokenTypes[tokenId] = nftType;
            
            emit NFTMinted(to, tokenId, nftType);
        }
    }
    
    /**
     * @dev Generate pseudo-random number
     * 注意：这不是真正的随机，但对于NFT分配足够了
     */
    function _getRandomNumber(uint256 tokenId) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.difficulty,
            block.number,
            msg.sender,
            tokenId,
            totalSupply()
        ))) % 100;
    }
    
    /**
     * @dev Determine rarity based on random number
     */
    function _determineRarity(uint256 randomValue) private pure returns (NFTType) {
        if (randomValue < 40) {
            return NFTType.GENESIS_BREAKER;  // 40% - Rare
        } else if (randomValue < 65) {
            return NFTType.CYBER_OVERFLOW;   // 25% - Ultra Rare
        } else if (randomValue < 85) {
            return NFTType.PAYLOAD_PHOENIX;  // 20% - Epic
        } else if (randomValue < 95) {
            return NFTType.INFINITE_BUFFER;  // 10% - Mythic
        } else {
            return NFTType.WEB3_LIBERATION;  // 5% - Legendary
        }
    }
    
    /**
     * @dev Check if token exists
     */
    function _tokenExists(uint256 tokenId) private view returns (bool) {
        return tokenId > 0 && tokenId < _tokenIdCounter.current();
    }
    
    /**
     * @dev Build attributes JSON for metadata
     */
    function _buildAttributes(string memory typeName, string memory rarity) private pure returns (string memory) {
        return string(abi.encodePacked(
            '[',
            '{"trait_type":"Type","value":"', typeName, '"},',
            '{"trait_type":"Rarity","value":"', rarity, '"},',
            '{"trait_type":"Generation","value":"Genesis"},',
            '{"trait_type":"Protocol","value":"x402 Powered"},',
            '{"trait_type":"Technology","value":"Gasless"},',
            '{"trait_type":"Error Code","value":"413 Breaker"}',
            ']'
        ));
    }
    
    /**
     * @dev Build metadata JSON part 1
     */
    function _buildMetadata(
        uint256 tokenId,
        string memory typeName,
        string memory rarity
    ) private pure returns (string memory) {
        return string(abi.encodePacked(
            '{"name":"4GIRL #', 
            tokenId.toString(), 
            ' - ', 
            typeName, 
            '","description":"Breaking the Web2 413 Payload Too Large error with blockchain technology. This ', 
            rarity, 
            ' NFT is powered by x402 gasless infrastructure.",'
        ));
    }
    
    /**
     * @dev Build metadata JSON part 2
     */
    function _buildMetadataPart2(
        uint256 tokenId,
        string memory imageFile,
        string memory attributes
    ) private pure returns (string memory) {
        return string(abi.encodePacked(
            '"image":"', 
            BASE_URI, 
            imageFile, 
            '","external_url":"https://4GIRL.io/token/', 
            tokenId.toString(), 
            '","background_color":"0A0A0A","attributes":', 
            attributes, 
            '}'
        ));
    }
    
    /**
     * @dev Returns the token URI for OpenSea - FULLY ON-CHAIN METADATA
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_tokenExists(tokenId) && ownerOf(tokenId) != address(0), "4GIRL: Token does not exist");
        
        NFTType nftType = tokenTypes[tokenId];
        string memory typeName = typeNames[nftType];
        string memory rarity = typeRarity[nftType];
        string memory imageFile = typeImages[nftType];
        
        string memory attributes = _buildAttributes(typeName, rarity);
        string memory part1 = _buildMetadata(tokenId, typeName, rarity);
        string memory part2 = _buildMetadataPart2(tokenId, imageFile, attributes);
        
        string memory json = string(abi.encodePacked(part1, part2));
        
        return string(abi.encodePacked(
            "data:application/json;base64,", 
            Base64.encode(bytes(json))
        ));
    }
    
    /**
     * @dev OpenSea contract-level metadata
     */
    function contractURI() public view returns (string memory) {
        string memory json = string(abi.encodePacked(
            '{"name":"4GIRL - Breaking Web2 Limits",',
            '"description":"4GIRL demonstrates how blockchain technology transcends traditional Web2 limitations. Built on x402 gasless infrastructure, we break through the 413 Payload Too Large error forever. Each NFT represents a different level of breakthrough power.",',
            '"image":"', 
            BASE_URI, 
            'collection.png","external_link":"https://4GIRL.io","seller_fee_basis_points":250,"fee_recipient":"0x', 
            toHexString(uint160(address(this)), 20), 
            '"}'
        ));
        
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }
    
    /**
     * @dev Convert address to hex string
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = 2 * length; i > 0; --i) {
            buffer[i - 1] = bytes1(uint8(value & 0xf) < 10 ? uint8(value & 0xf) + 0x30 : uint8(value & 0xf) + 0x57);
            value >>= 4;
        }
        return string(buffer);
    }
    
    /**
     * @dev Get all tokens owned by an address
     */
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokens = new uint256[](tokenCount);
        
        for (uint256 i = 0; i < tokenCount; i++) {
            tokens[i] = tokenOfOwnerByIndex(owner, i);
        }
        
        return tokens;
    }
    
    /**
     * @dev Get token details
     */
    function getTokenDetails(uint256 tokenId) external view returns (
        NFTType nftType,
        string memory typeName,
        string memory rarity,
        string memory imageUrl
    ) {
        require(_tokenExists(tokenId) && ownerOf(tokenId) != address(0), "4GIRL: Token does not exist");
        
        nftType = tokenTypes[tokenId];
        typeName = typeNames[nftType];
        rarity = typeRarity[nftType];
        imageUrl = string(abi.encodePacked(BASE_URI, typeImages[nftType]));
    }
    
    /**
     * @dev Get mint statistics
     */
    function getMintStats() external view returns (
        uint256 currentSupply,
        uint256 maxSupply,
        uint256 userBalance,
        uint256 maxPerWallet
    ) {
        currentSupply = totalSupply();
        maxSupply = MAX_SUPPLY;
        userBalance = balanceOf(msg.sender);
        maxPerWallet = MAX_PER_WALLET;
    }
    
    /**
     * @dev Check how many NFTs a wallet has minted
     */
    function getMintedCount(address wallet) external view returns (uint256) {
        return mintedPerWallet[wallet];
    }
    
    /**
     * @dev Check remaining mints for a wallet
     */
    function getRemainingMints(address wallet) external view returns (uint256) {
        uint256 minted = mintedPerWallet[wallet];
        if (minted >= MAX_PER_WALLET) {
            return 0;
        }
        return MAX_PER_WALLET - minted;
    }
    
    /**
     * @dev Admin functions
     */
    function setMintingEnabled(bool enabled) external onlyOwner {
        mintingEnabled = enabled;
    }
    
    /**
     * @dev Withdraw (for any accidentally sent funds)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "4GIRL: No balance");
        payable(owner()).transfer(balance);
    }
    
    /**
     * @dev Required overrides for ERC721Enumerable
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}