# PayBox Documentation: A Comprehensive Overview.

**The Paybox contract is primarily designed to manage the payment and attendance system for a company or organization. It operates on the Polygon zkevm blockchain, a decentralized technology that executes smart contracts.**

The payment system within the Paybox contract is token-based, adhering to the ERC-20 and ERC721 standards, common standards for tokens on the Ethereum blockchain. This ensures that the tokens used within the Paybox system can be easily transferred, awarded as Certificate, or spent, similar to any other ERC-20 and ERC721 tokens.

### Structure of PayBox

#### Front-End
Paybox front-end built with WAGMI, RainbowKit, and Vercel offers a robust interface solution for interacting with the smart contract for users
- **WAGMI (We're All Gonna Make It)**

     A set of React Hooks for simplifying the process of connecting a Web3 frontend to the blockchain.It manages wallet connections and network status, facilitating querying and writing to the blockchain. Used to write React components that interact with smart contracts.

- **RainbowKit**

    A React library that provides wallet connection components. With user-friendly wallet connection interface, Customizable and themable to match application UI. Integrated with WAGMI to handle wallet connections in a user-friendly manner

- **Vercel** 

    Easy deployment and hosting of web applications. Automatic scaling, SSL, and global CDN. Also, integrates well with GitHub for CI/CD.


#### Back-End
A factory smart contract deployed on the [Polygon-zkevm](#https://testnet-zkevm.polygonscan.com/address/0x55ab9da672143f1637be8072c3042f42ffe3cc03) blockchain for a seamless and secure transactions. The execution of transactions (salary disbursment) leverages the [ChainLink Automation](#https://docs.chain.link/chainlink-automation), using time-based trigger.

- **[Polygon-zkevm](#https://testnet-zkevm.polygonscan.com/address/0x55ab9da672143f1637be8072c3042f42ffe3cc03)**

    Deploying the payBox smart contract on Polygon's Zero-Knowledge Ethereum Virtual Machine (ZK-EVM) harnesses the platform's enhanced scalability, reduced gas costs, and privacy features of zero-knowledge proofs, ideal for handling frequent, sensitive transactions like salary distributions. The EVM compatibility facilitates easy migration from Ethereum, leveraging familiar development tools while ensuring robust security. Additionally, Polygon's energy-efficient framework aligns with sustainable technology deployment, making it an optimal choice for payBox in balancing performance, cost-effectiveness, and environmental considerations.

- **[ChainLink Automation](#https://docs.chain.link/chainlink-automation)**

    Utilizing [ChainLink Automation](#https://docs.chain.link/chainlink-automation) for the payBox smart contract brings significant operational efficiency and reliability. [ChainLink Automation](#https://docs.chain.link/chainlink-automation) ensures critical functions within payBox, like periodic salary distributions and attendance resets, are executed autonomously and accurately, based on predefined condition(time-based trigger). This integration eliminates the need for manual interventions, reducing human error and streamlining the contract's functionality. Moreover, it leverages Chainlink's decentralized network, ensuring high availability and tamper-proof operations, crucial for maintaining the integrity of financial transactions and record-keeping in payBox. The use of Chainlink Automation thus enhances the overall robustness and effectiveness of the payBox contract's operations.



### Features of the PayBox Contract
The Paybox contract has several key responsibilities:

1. **Token Management**: The contract manages an ERC-20 token, which is used for payments within the system. This includes transferring tokens between accounts and approving tokens to be spent by others.

2. **Salary Management**: The contract maintains a record of the salary for each staff member. This is achieved using a mapping, a type of data structure in Solidity that allows for efficient lookups.

3. **Attendance Management**: The contract also manages the attendance of staff members. It keeps track of whether each staff member has marked their attendance for the day, and it counts the number of days each staff member has attended.

4. **Profile Management**: The contract stores a profile for each staff member. This includes the staff member's address, name, position, salary, and email.

5. **Time Management**: The contract keeps track of the last time the attendance was reset. It also sets an interval for resetting the attendance.

## Interacting with the Contract
Deploy the contract using a tool like Foundry, Hardhat or Remix, providing the necessary constructor parameters.
Once deployed, interact with the contract functions using either a web3 interface or directly through a Solidity environment.
For salary distributions, ensure that the ERC20 token balance in the contract is sufficient.

NOTE: For easier interaction, click on the provided testnet links, connect your web3 wallet and start interacting with the contract. Ensure you have all requirements to interact below;

#### Prerequisites
- Familiarity with Ethereum, Solidity, and smart contract interactions.
- Access to an Ethereum wallet with sufficient ETH for transaction fees(e.g Metamask, trustwallet).
- ERC20 tokens for salary payments.
- ERC721 tokens for award certifications
- A tool like Remix, Foundry, or Hardhat for deploying and interacting with the contract.

### STEP 1 - Set up Foundry Project
To begin setting up the environment for the smart contract implementation, you will first need to create a new folder on your system. You can do this by using the ‘mkdir’ command in your terminal followed by the desired name of your folder. For example:

    ```
    mkdir PayBox
    ```
Next, navigate to your project folder using the ‘cd’ command, like below:

    ```
    cd  PayBox
    ```
Once you have cd into the folder, you can clone the project inside it by running the following command:

    ```
    git clone https://github.com/paybox-org/smartcontract.git 
    ```

This will clone the project folder, and then install the project dependencies by running;

    ```
    forge install
    ```

Finally, open your project folder in VScode by running this command in your terminal:

    ```
    code .
    ```
This will open up your project folder in Visual Studio Code, where you can use the following foundry commands.

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy and Verify

```shell
$ forge create --rpc-url <rpc url> \
    --constructor-args <constructor args>\
    --private-key <private key> \
    --etherscan-api-key <API-KEY> \
    --verify \
    src/game.sol:MyGame
```

### Help

```shell
$ forge --help
```
https://book.getfoundry.sh/

# Usage


## Key Functions (PayBox Factory Contract).

### showMyAcct

The function showMyAcct is a public view function that takes an address parameter called _owner and returns an address value. It is a function in the payboxFactory contract. The purpose of this function is to retrieve the account address created by the specified _owner. The function takes the _owner address as input and returns the corresponding account address created by that _owner. This function is useful for users to retrieve their account address after creating an account using the createAccount function.

**Parameters**

The **_owner** parameter is an address value that represents the owner of the account. It is used to retrieve the account address created by the specified _owner.

### createAccount

The createAccount function is an external function that allows users to create a company account. It takes the following parameters:- 

- **_tokenAddress**: the address of an ERC721 token

- **_nftName**: a string representing the name of the ERC721 token
- **_nftSymbol**: a string representing the symbol of the ERC721 token
- **_Nfturi**: a string representing the URI of the ERC721 token
- **_companyName**: a string representing the name of the company
- **_companyLogo**: a string representing the logo of the company
- **_email**: a string representing the email address of the company

**NOTE** : Before calling this function, the user must not have an existing account, as indicated by the require statement ```require(!userExist[_caller], "user account created")```.

The function creates a new instance of the payboxDashboard contract, passing the provided parameters. It then stores the address of the newly created contract in the myAccount mapping, with the user's address as the key. Finally, it emits an AccountCreated event with the caller's address and the address of the newly created contract.

**Returns Boolean**

The function returns a boolean value indicating the success of the account creation process.

## Key Functions (PayBox Dashboard)
Paybox Dashboard is the factory child contract that will be created when the **createAccount** method has been interacted with.

### Adding Staff (addStaff)

**Purpose**: 

Adds new staff members to the contract.

- **Parameters**:

    **_staffAddresses**: Array of staff Ethereum addresses.

    **_amount**: Array of salary amounts corresponding to each staff member.

    **_name, _position, _email**: Arrays of staff names, positions, and emails.

    **Usage**: This function can only be called by the contract owner.


### Removing Staff (removeStaff):

**Purpose**: 

Removes a staff member from the contract.

- **Parameters**:

    **_staff**: Ethereum address of the staff member to be removed.

    **Usage**: Only the contract owner can execute this function.

### Salary Payment (salaryPayment):

**Purpose**: 

Distributes salaries to all staff members and rewards the best employee with an NFT.

- **Usage**: Initiated by the contract owner. Ensure sufficient ERC20 tokens are deposited in the contract.

### Depositing Funds (depositFund):

**Purpose**: 

Deposits ERC20 tokens into the contract for salary payouts.

**Parameters**:
- **_amount**: Amount of ERC20 tokens to deposit.

    **Usage**: Anyone can deposit, but typically performed by the contract owner or finance department.

### Withdrawing Funds (withdrawFund):

**Purpose**: 

Withdraws ERC20 tokens from the contract.

**Parameters**:

- **to**: Address to receive the withdrawn tokens.
- **_amount**: Amount of tokens to withdraw.

    **Usage**: Restricted to the contract owner.

### Opening Attendance (openAttendance):

**Purpose**: 

Initiates a new attendance cycle.

- **Usage**: Executed by the contract owner, typically at the start of a workday.

### Marking Attendance (markAttendance):

**Purpose**: Allows staff to mark their attendance.
- **Usage**: Can be executed by any staff member once per day.


### Related EIPs/ERCs
The Paybox contract is related to the following Ethereum Improvement Proposals (EIPs) and Ethereum Request for Comments (ERCs):

**ERC-20**: This is the standard for fungible tokens on the Ethereum network. The Paybox contract adheres to this standard for easy disbursment of employees' salaries.

**ERC-223**: This is a proposed standard for token transfers. It suggests a function to handle token transfers and prevent tokens from being lost in unhandled transactions.

**ERC-721**: This is the standard for non-fungible tokens on the Ethereum network. The Paybox contract implements this to transfer non-fungible tokens, for company's award certification.

### Contract Addresses (Testnet)
- **Polygon zkevm** : https://testnet-zkevm.polygonscan.com/address/0x55ab9da672143f1637be8072c3042f42ffe3cc03

- **Sepolia** : https://sepolia.etherscan.io/address/0x32ad2bcae4c7a6fae0278930d9053cb2bc4bba77#writeContract

#### Token
 - **Polygon zkevm** :https://testnet-zkevm.polygonscan.com/address/0xfc0bc66653d892534df9c2c4eb289e15b90b49cf
 - **Sepolia** : https://sepolia.etherscan.io/address/0xf80f593c828bfc4ead99897c6b780f539256d7ff#writeContract
