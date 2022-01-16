# The Web3 WP Wapuu NFT Project

Wapuu is the lovable, open source, and (un)official mascot of WordPress. Wapuu swag has been created and collected at WordCamps around the world. Web3 WP took the next step by building a generative art project of 2,222 unique Finns that can be minted as an NFT, collected, and traded by the WordPress community on the Ethereum blockchain.

![Finns](https://web3wp.infiniteuploads.cloud/2021/09/wapuu-designs.png)

We review the use of this code in detail on [our blog at Web3 WP](https://web3wp.com/blog/).

Run `yarn` (install yarn globally if you havn't yet) on the root dir to install most requirements.

### This repo contains 4 distinct apps that work together:

## The Smart Contract

At it's heart, an NFT is built on a smart contract that is deployed to the blockchain. You can find the smart contracts for this project in the /contracts/ directory. We started off building the project as an ERC721 contract (/contracts/Finn_ERC721.sol), but ultimately for efficiency we rewrote it as an ERC1155 contract, and that is what is being used in production.

For smartcontract development we use [Hardhat](https://hardhat.org/getting-started/), which handles compiling, running a local node, automated testing, and deploying to local, rinkeby testnet, or mainnet.

The config is in *hardhat.config.js*. Rename sample.env to .env and populate it with the needed config variables. All are optional for local testing and described in the config. Imported Openzeppelin base contracts are installed via npm/yarn.

**Commands:**

- Run automated tests (see /test/test.js): `yarn run test`
- Start a local node to test the client app against: `yarn run local-node`
- Compile & deploy smart contract (end with localhost, rinkeby, or mainnet): `yarn run contract-deploy localhost`
- Verify the smart contract on Etherscan (end with rinkeby, or mainnet): `yarn run contract-verify rinkeby`

## The Frontend Website App

The website is built with Next.js + Tailwind CSS. It can be deployed to Next.js hosting like Vercel/Netlify, or as we did can be exported as static html and deployed on any host or CDN like Cloudflare Pages for unlimited scalability.

The config is in *next.config.js*. The *config.json* file needs to contain the smart contract address and ABI (interface specification in json), which is used by the web3.js library to interact with the smart contract via the user's wallet. Our contract deploy script above will write this config whenever it's deployed.

**Commands:**

- Run the Next.js local development environment on http://localhost:3000: `yarn run dev`

## The Metadata API

NFT smart contracts do not save the metadata for each token as that would be way too expensive. Instead they reveal a tokenURI() or uri() method that returns the url where you can find the metadata for a specific NFT tokenId. You could save this metadata to the IPFS blockchain, but that would make it possible during the minting process for someone to preview all the Finns that are yet to be minted and removes the aspect of chance. Instead we build a simple node.js API using the Serverless framework deployed to AWS Lambda for unlimited scalability.

Opensea Metadata Standard: https://docs.opensea.io/docs/metadata-standards

All API code is in the */api/* directory. Enter that directory then run `npm install` to install all dependencies. To avoid revealing secret information before all Finns are minted, we only include sample config/metadata files. You will need to rename and edit:

- Wapuu metadata (this is generated by our Wapuu generation script): *api/all-traits.sample.json* to *api/all-traits.json*
- Configurations for dev/prod stages (same data as config.json and an Infura API url): *api/config-dev.sample.json* to *api/config-dev.json*
- The whitelist of addresses for distributing our POAP: *api/og-collectors.sample.json* to *api/og-collectors.json*

The main code for the 3 API endpoint is in *api/handler.js*. Main [Serverless](https://www.serverless.com/framework/docs) config is *serverless.yml*.

**Commands:**

- Deploy to develop stage for testing: `npm run deploy-dev`
- Deploy to production stage: `npm run deploy-prod`
- View logs for dev Finns endpoint: `npm run logs-Finns`
- View logs for dev verify endpoint: `npm run logs-verify`

## The Wapuu Image/Trait Generator

We built a programmatic generator that creates completely unique Wapuu characters based on a random set of more than one hundred distinct traits like hair, hats, accessories, clothing, holding items, and colors. Traits are weighted to have various rarities, some are very common, and some may only be found on a lucky handful of Finns. All these traits were created as transparent PNG layers, and the python script combines the layers to create the final Finns and their JSON metadata. This can all be found in *image_generator/* directory.

This repo only includes some samples traits of each layer as a starting point in the *image_generator/trait-layers* directory. 1-of-1 special edition Finns were placed in the *image_generator/completes/* directory and their special metadata defined in *image_generator/metadata/special-Finns.json*.

**Python scripts:**

- Generate Finns: `python generate.py`
- Deploy to IPFS: `python upload_ipfs.py`
- Refresh OpenSea metadata (we used this occasionally after a big mint to speed up reveal): `python opensea_refresh.py`
