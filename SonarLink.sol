// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SonarLink is ERC721, ERC721URIStorage, Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 private constant PREMIUM_SUBSCRIPTION_DURATION = 30 days;

    IERC20 public etherToken;

    uint256 private constant COMMISSION_DIVIDER = 100;
    uint256 private constant SONG_PURCHASE_COMMISSION = 5; // 5%
    uint256 private constant SONG_PLAY_COMMISSION = 10; // 10%
    uint256 private constant PREMIUM_SUBSCRIPTION_FEE = 0.0033 ether; // 0.0033 Ether

    address public sonarlink;
    address public songCreator;
    
struct Artist {
    address owner;
    string name;
    uint256 artistId;
}

struct Song {
    string title;
    string artist;
    string uri;
    address payable owner;
    bool isNFT;
    uint256 price;
    string genre;
    string coverImageUrl;
    string lyrics;
    uint256 collaborationCount;
    uint256[] tokenIds;
    string performedBy;
    string writtenBy;
    string producedBy;
    string links;
}

    struct Playlist {
        string name;
        address owner;
        uint256[] songIds;
    }

 struct License {
        string name;
        string description;
        uint256 price;
    }

    struct Copyright {
    uint256 songId;
    address owner;
    uint256 price;
}

struct LiveEvent {
    string title;
    string description;
    uint256 date;
    uint256 price;
    address payable artist;
    bool isCanceled;
}

struct Follower {
    address follower;
    address following;
}

struct Rating {
    address rater;
    uint256 songId;
    uint8 rating;
}

struct Comment {
    address commenter;
    uint256 songId;
    string content;
}

    mapping(uint256 => Artist) public artists;
    mapping(uint256 => Song) public songs;
    mapping(uint256 => uint256) public songPlays;
    mapping(uint256 => Playlist) public playlists;
    mapping(string => uint256[]) public genreToSongs;
    mapping(string => uint256[]) public artistToSongs;
    mapping(address => uint256) public artistStats;
    mapping(uint256 => License[]) public songLicenses;
    mapping(address => uint256) public premiumSubscriptions;
    mapping(uint256 => LiveEvent) public liveEvents;
    mapping(address => address[]) public userFollowings;
    mapping(address => address[]) public userFollowers;
    mapping(uint256 => Rating[]) public songRatings;
    mapping(uint256 => Comment[]) public songComments;
    mapping(uint256 => Copyright) public copyrightRegistrations;

    event SongRegistered(uint256 indexed tokenId, string title, string artist, address owner);
    event SongPurchased(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event SongPlayed(uint256 indexed tokenId);
    event PlaylistCreated(uint256 indexed playlistId, string name, address owner);
    event SongAddedToPlaylist(uint256 indexed playlistId, uint256 indexed tokenId);
    event SongRemovedFromPlaylist(uint256 indexed playlistId, uint256 indexed tokenId);
    event PremiumSubscriptionPurchased(address indexed subscriber, uint256 expiryTimestamp);
    event LicensePurchased(uint256 indexed tokenId, address indexed buyer, uint256 licenseIndex);
    event FreeSongPlayed(uint256 indexed tokenId, address indexed listener);
    event LiveEventCreated(uint256 indexed eventId, string title, string description, uint256 date, address indexed artist);
    event LiveEventCanceled(uint256 indexed eventId, address indexed artist);
    event LiveEventTicketPurchased(uint256 indexed eventId, address indexed buyer);
    event UserFollowed(address indexed follower, address indexed following);
    event UserUnfollowed(address indexed follower, address indexed following);
    event SongRated(uint256 indexed songId, address indexed rater, uint8 rating);
    event SongCommented(uint256 indexed songId, address indexed commenter, string content);
    event CopyrightRegistered(uint256 indexed songId, address indexed owner, uint256 price);
    event CopyrightPurchased(uint256 indexed songId, address indexed buyer, uint256 price);


 constructor(address _etherTokenAddress) ERC721("SonarLink", "SL") {
        etherToken = IERC20(_etherTokenAddress);
        transferOwnership(msg.sender);
        songCreator = msg.sender;
    }

function registerSong(string memory title, string memory artist, string memory uri, bool isNFT, uint256 price, string memory genre, string memory coverImageUrl, string memory lyrics, string memory performedBy, string memory writtenBy, string memory producedBy, string memory links) public onlyOwner whenNotPaused {
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();

    _mint(owner(), tokenId);
    _setTokenURI(tokenId, uri);

    etherToken.transferFrom(msg.sender, songCreator, price); // Transfer tokens to the SongCreator contract

    songs[tokenId] = Song(
        title,
        artist,
        uri,
        payable(owner()),
        isNFT,
        price,
        genre,
        coverImageUrl,
        lyrics,
        0,
        new uint256[](0),
        performedBy,
        writtenBy,
        producedBy,
        links
    );

    emit SongRegistered(tokenId, title, artist, owner());
}

function purchaseSong(uint256 tokenId) public payable whenNotPaused {
    require(_exists(tokenId), "Token ID no existe");
    require(songs[tokenId].isNFT, "La cancion no es un NFT");
    require(msg.value >= songs[tokenId].price, "El precio enviado es insuficiente");
    require(songs[tokenId].owner != msg.sender, "No puedes comprar tu propia cancion");

    bool found = false;
    for (uint256 i = 0; i < songs[tokenId].tokenIds.length; i++) {
        if (songs[tokenId].tokenIds[i] == tokenId) {
            found = true;
            break;
        }
    }
    require(found, "El token ID no corresponde a esta cancion");

    address payable previousOwner = songs[tokenId].owner;
    uint256 commission = (msg.value * SONG_PURCHASE_COMMISSION) / COMMISSION_DIVIDER;
    uint256 royalties = (msg.value * SONG_PLAY_COMMISSION) / COMMISSION_DIVIDER;
    uint256 paymentToOwner = msg.value - commission - royalties;

    _transfer(previousOwner, msg.sender, tokenId);
    songs[tokenId].owner = payable(msg.sender);

    previousOwner.transfer(paymentToOwner);

    // Actualización: enviar comisiones y regalías directamente al propietario del contrato
    payable(owner()).transfer(commission + royalties);

    emit SongPurchased(tokenId, msg.sender, msg.value);
}

function playSong(uint256 tokenId, bool adEnabled) public {
        require(_exists(tokenId), "Token ID no existe");

        if (!adEnabled) {
            require(premiumSubscriptions[msg.sender] > block.timestamp, "La suscripcion premium no es valida o ha expirado");
        }

        if (adEnabled) {
            emit FreeSongPlayed(tokenId, msg.sender);
        } else {
            emit SongPlayed(tokenId);
        }
        songPlays[tokenId]++;
    }

function purchasePremiumSubscription() public payable whenNotPaused {
        require(msg.value >= PREMIUM_SUBSCRIPTION_FEE, "El precio enviado es insuficiente");

        uint256 currentExpiry = premiumSubscriptions[msg.sender];
        if (currentExpiry < block.timestamp) {
            currentExpiry = block.timestamp;
        }
        premiumSubscriptions[msg.sender] = currentExpiry + PREMIUM_SUBSCRIPTION_DURATION;

        // Transferir la tarifa de suscripción al propietario del contrato
        payable(owner()).transfer(msg.value);

        emit PremiumSubscriptionPurchased(msg.sender, premiumSubscriptions[msg.sender]);
    }

function createPlaylist(string memory name) public {
    uint256 playlistId = _tokenIds.current();
    playlists[playlistId] = Playlist(name, msg.sender, new uint256[](0));

    emit PlaylistCreated(playlistId, name, msg.sender);
}

function addSongToPlaylist(uint256 playlistId, uint256 tokenId) public {
    require(playlists[playlistId].owner == msg.sender, "Solo el propietario de la lista de reproduccion puede agregar canciones");

    playlists[playlistId].songIds.push(tokenId);

    emit SongAddedToPlaylist(playlistId, tokenId);
}

function removeSongFromPlaylist(uint256 playlistId, uint256 tokenId) public whenNotPaused {
    require(playlists[playlistId].owner == msg.sender, "Solo el propietario de la lista de reproduccion puede eliminar canciones");

    uint256 songIndex;
    bool found = false;
    for (uint256 i = 0; i < playlists[playlistId].songIds.length; i++) {
        if (playlists[playlistId].songIds[i] == tokenId) {
            songIndex = i;
            found = true;
            break;
        }
    }
    require(found, "La cancion no se encuentra en la lista de reproduccion");

    playlists[playlistId].songIds[songIndex] = playlists[playlistId].songIds[playlists[playlistId].songIds.length - 1];
    playlists[playlistId].songIds.pop();

    emit SongRemovedFromPlaylist(playlistId, tokenId);
}

function withdraw() public onlyOwner {
    payable(sonarlink).transfer(address(this).balance);
}

// Implementar las funciones heredadas de ERC721URIStorage
function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
}

function tokenURI(uint256 tokenId) public view override
(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
}

    function searchSongsByGenre(string memory genre) public view returns (uint256[] memory) {
        return genreToSongs[genre];
    }

    function searchSongsByArtist(string memory artist) public view returns (uint256[] memory) {
        return artistToSongs[artist];
    }

    function addSongMetadata(uint256 tokenId, string memory genre) public {
        require(songs[tokenId].owner == msg.sender, "Solo el propietario de la cancion puede agregar metadatos");

        songs[tokenId].genre = genre;
        genreToSongs[genre].push(tokenId);
        artistToSongs[songs[tokenId].artist].push(tokenId);
    }

    function getArtistStats(address artist) public view returns (uint256) {
        return artistStats[artist];
    }

    function shareSongToSocialMedia(uint256 tokenId, string memory socialMediaPlatform) public {
}

    function addLicenseToSong(uint256 tokenId, string memory name, string memory description, uint256 price) public {
        require(songs[tokenId].owner == msg.sender, "Solo el propietario de la cancion puede agregar licencias");
       songLicenses[tokenId].push(License(name, description, price));
}

function purchaseLicense(uint256 tokenId, uint256 licenseIndex, address licenseTokenAddress) public whenNotPaused {
License[] storage licenses = songLicenses[tokenId];
require(licenseIndex < licenses.length, "Licencia no encontrada");
License storage license = licenses[licenseIndex];

IERC20 token = IERC20(licenseTokenAddress);
require(token.balanceOf(msg.sender) >= license.price, "No tiene suficientes tokens de licencia");

token.transferFrom(msg.sender, owner(), license.price);

_safeMint(msg.sender, _tokenIds.current());
_setTokenURI(_tokenIds.current(), tokenURI(tokenId));

emit LicensePurchased(_tokenIds.current(), msg.sender, licenseIndex);
_tokenIds.increment();
}

function registerCopyright(uint256 songId, uint256 price) public whenNotPaused {
    require(songs[songId].owner == msg.sender, "Solo el propietario de la cancion puede registrar los derechos de autor");

    copyrightRegistrations[songId] = Copyright(songId, msg.sender, price);

    emit CopyrightRegistered(songId, msg.sender, price);
}

function purchaseCopyright(uint256 songId) public payable {
    Copyright storage copyright = copyrightRegistrations[songId];

    require(copyright.owner != address(0), "Los derechos de autor no estan registrados");
    require(msg.value >= copyright.price, "El precio enviado es insuficiente");
    require(copyright.owner != msg.sender, "No puedes comprar tus propios derechos de autor");

    address payable previousOwner = payable(copyright.owner);
    uint256 commission = (msg.value * SONG_PURCHASE_COMMISSION) / COMMISSION_DIVIDER;
    uint256 paymentToOwner = msg.value - commission;

    copyright.owner = msg.sender;
    previousOwner.transfer(paymentToOwner);

    // Transferir la comisión al propietario del contrato
    payable(owner()).transfer(commission);

    emit CopyrightPurchased(songId, msg.sender, msg.value);
}

function createLiveEvent(string memory title, string memory description, uint256 date, uint256 price) public whenNotPaused {
    uint256 eventId = _tokenIds.current();
    liveEvents[eventId] = LiveEvent(title, description, date, price, payable(msg.sender), false);

    emit LiveEventCreated(eventId, title, description, date, msg.sender);
    _tokenIds.increment();
}

function cancelLiveEvent(uint256 eventId) public whenNotPaused {
    require(liveEvents[eventId].artist == msg.sender, "Solo el artista puede cancelar el evento en vivo");
    require(!liveEvents[eventId].isCanceled, "El evento en vivo ya esta cancelado");

    liveEvents[eventId].isCanceled = true;

    emit LiveEventCanceled(eventId, msg.sender);
}

function purchaseLiveEventTicket(uint256 eventId) public payable whenNotPaused {
    require(!liveEvents[eventId].isCanceled, "El evento en vivo esta cancelado");
    require(liveEvents[eventId].date > block.timestamp, "El evento en vivo ya ha ocurrido");
    require(msg.value >= liveEvents[eventId].price, "El precio enviado es insuficiente");

    liveEvents[eventId].artist.transfer(msg.value);

    emit LiveEventTicketPurchased(eventId, msg.sender);
}
function followUser(address following) public {
    require(msg.sender != following, "No puedes seguirte a ti mismo");

    userFollowings[msg.sender].push(following);
    userFollowers[following].push(msg.sender);

    emit UserFollowed(msg.sender, following);
}

function unfollowUser(address following) public whenNotPaused {
    uint256 index;
    bool found = false;
    for (uint256 i = 0; i < userFollowings[msg.sender].length; i++) {
        if (userFollowings[msg.sender][i] == following) {
            index = i;
            found = true;
            break;
        }
    }

    require(found, "No sigues a este usuario");

    userFollowings[msg.sender][index] = userFollowings[msg.sender][userFollowings[msg.sender].length - 1];
    userFollowings[msg.sender].pop();

    emit UserUnfollowed(msg.sender, following);
}

function rateSong(uint256 songId, uint8 rating) public whenNotPaused {
    require(rating >= 1 && rating <= 5, "La calificacion debe estar entre 1 y 5");

    songRatings[songId].push(Rating(msg.sender, songId, rating));

    emit SongRated(songId, msg.sender, rating);
}

function commentSong(uint256 songId, string memory content) public {
    songComments[songId].push(Comment(msg.sender, songId, content));

    emit SongCommented(songId, msg.sender, content);
}

function getSongInfo(uint256 tokenId) public view returns (string memory title, string memory artist, string memory uri, address owner, bool isNFT, uint256 price, string memory genre, string memory performedBy, string memory writtenBy, string memory producedBy, string memory links, string memory coverImageUrl, string memory lyrics) {
    require(_exists(tokenId), "Token ID does not exist");
    Song storage song = songs[tokenId];
    return (
        song.title,
        song.artist,
        song.uri,
        song.owner,
        song.isNFT,
        song.price,
        song.genre,
        song.performedBy,
        song.writtenBy,
        song.producedBy,
        song.links,
        song.coverImageUrl,
        song.lyrics
    );
}

// Pause and Unpause functions, only accessible by the contract owner
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
