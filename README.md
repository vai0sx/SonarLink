# SonarLink

SonarLink is a decentralized music platform built on the Ethereum blockchain. It allows artists to register and sell their songs as NFTs (Non-Fungible Tokens) and provides various features for music enthusiasts.

## Features

- Song Registration: Artists can register their songs on the platform by providing metadata such as title, artist, genre, cover image, lyrics, and more. The songs are stored as ERC721 tokens.
- Song Purchase: Users can purchase songs by paying the specified price in Ether. A commission is distributed to the platform owner and the song creator.
- Song Play: Users can play the purchased songs. Premium subscribers can enjoy ad-free listening.
- Premium Subscription: Users can purchase a premium subscription to access ad-free listening for a specified duration.
- Playlists: Users can create and manage playlists by adding songs to them.
- Licensing: Artists can add licenses to their songs, allowing others to purchase rights to use the songs.
- Copyright Registration: Artists can register their songs' copyrights on the blockchain.
- Live Events: Artists can create live events and sell tickets to users.

## Getting Started

To deploy the SonarLink contract and use the platform, follow these steps:

1. Install the required dependencies by running `npm install`.
2. Compile the smart contract by running `npx hardhat compile`.
3. Deploy the contract to a network of your choice using Hardhat or any other Ethereum deployment tool.
4. Interact with the contract using the provided functions and the Ethereum wallet of your choice.

## Dependencies

SonarLink uses the following dependencies:

- OpenZeppelin: A library for secure smart contract development, including ERC721 and other standards.
- Counters: A library for managing counter variables used in the contract.
- IERC20: An interface for interacting with ERC20 tokens.

Make sure to install these dependencies before deploying and interacting with the contract.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

