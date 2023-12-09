# PayBox Documentation: A Comprehensive Overview.
**The Paybox contract is primarily designed to manage the payment and attendance system for a company or organization. It operates on the Polygon zkevm blockchain, a decentralized technology that executes smart contracts.**

The payment system within the Paybox contract is token-based, adhering to the ERC-20 and ERC721 standards, common standards for tokens on the Ethereum blockchain. This ensures that the tokens used within the Paybox system can be easily transferred, awarded as Certificate, or spent, similar to any other ERC-20 and ERC721 tokens.

### Structure of the PayBox Contract
The Paybox contract has several key responsibilities:

- **Token Management**: The contract manages an ERC-20 token, which is used for payments within the system. This includes transferring tokens between accounts and approving tokens to be spent by others.

- **Salary Management**: The contract maintains a record of the salary for each staff member. This is achieved using a mapping, a type of data structure in Solidity that allows for efficient lookups.

- **Attendance Management**: The contract also manages the attendance of staff members. It keeps track of whether each staff member has marked their attendance for the day, and it counts the number of days each staff member has attended.

- **Profile Management**: The contract stores a profile for each staff member. This includes the staff member's address, name, position, salary, and email.

- **Time Management**: The contract keeps track of the last time the attendance was reset. It also sets an interval for resetting the attendance.

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


## Key Functions (PayBox Factory Contract)


### showMyAcct

The function showMyAcct is a public view function that takes an address parameter called _owner and returns an address value. It is a function in the payboxFactory contract. The purpose of this function is to retrieve the account address created by the specified _owner. The function takes the _owner address as input and returns the corresponding account address created by that _owner. This function is useful for users to retrieve their account address after creating an account using the createAccount function.

**Parameters**

The **_owner** parameter is an address value that represents the owner of the account. It is used to retrieve the account address created by the specified _owner.



## Key Functions (PayBox Dashboard)

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