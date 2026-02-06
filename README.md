# The study result, dataset and code for OOPSLA 2026 Artifact Evaluation

## Paper Overview

**SymGPT: Auditing Smart Contracts via Combining Symbolic
Execution with Large Language Models**

This paper introduces SymGPT, a tool that combines LLMs with symbolic execution to automatically verify
smart contracts’ compliance with ERC rules. We begin by empirically analyzing 132 ERC rules from three
major ERC standards, examining their content, security implications, and natural language descriptions. Based
on this study, SymGPT instructs an LLM to translate ERC rules into a defined EBNF grammar, synthesizes
constraints from the translated rules to model potential rule violations, and performs symbolic execution
for violation detection. Our evaluation shows that SymGPT identifies 5,783 ERC rule violations in 4,000 real-
world contracts, including 1,375 violations with clear attack paths for financial theft. Furthermore, SymGPT
outperforms six automated techniques and a security-expert auditing service, underscoring its superiority
over current smart contract analysis methods.

## Artifact Expectation

The information of our study is released in an excel file/google sheet. The the dataset and code are released in a virtual machine that is created using Virtual Box 7.2.6, We expect users to use a Virtual Box of this version or higher to start the VM.

## Artifact Overview

### Prerequistes
- OS: Ubuntu >= 22.xx
- Python == 3.12.x
- Docker (required for running baseline tools)
- Z3
- Git
  
#### Prerequistes Setup
- Skip following commands if you are in the Ubuntu system in provided virtual box image
- Run following commands if you are in another Ubuntu system
  - Feel free to skip the installation if you are sure if it has been installed
```bash
$ sudo apt update

# install Git
$ sudo apt install -y git 

# install z3
$ sudo apt install -y z3

# install docker
$ sudo apt install -y ca-certificates curl
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$  sudo chmod a+r /etc/apt/keyrings/docker.asc
$ sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
$ sudo apt update
$ sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# install python
$ sudo add-apt-repository ppa:deadsnakes/ppa
$ sudo apt update
$ sudo apt install -y python3.12
$ sudo apt install -y python3-pip
```

### Project Setup
- Make sure you have all the prerequistes installed before you proceed next
```bash
# Create Python virtual environment
$ python3 -m venv .venv

# Activate the virtual environment in the terminal
$ source .venv/bin/activate

# Install the dependencies
$ pip install -r requirements.txt
```

## Quick Start (Kick-the-Tires)
These commands can quickly find out ERC violations mentioned in the paper figures!
### Audit Contract in Figure 1 

#### Audit a smart contract at benchmark/large/0xa47a731dcd4267893c5c210056476d404088521a.sol
```bash
$ ./x audit benchmark/large/0xa47a731dcd4267893c5c210056476d404088521a.sol --out-dir 0xa47a
# This command will output an json file at <out-dir>/<sol-file-name>.json which contains the audit result.
# In this command, output json file will be at 0xa47a/0xa47a731dcd4267893c5c210056476d404088521a.json
```

#### Output file is located at 0xa47a/0xa47a731dcd4267893c5c210056476d404088521a.json
- This example output file is decorated with the instruction comment for how to intepreting the result
- The violation below "!!!!!!" is the paper's figure 1 mentioned violation (violated rule is highlighed in figure 2)
```json
{
    "sol_file": "benchmark/large/0xa47a731dcd4267893c5c210056476d404088521a.sol",  # <---- This indicates this file is audit result of which solidity source file
    "contract": {
        "TicketOwnership": [      # <---- This indicates name of the contract that is been audited
            {
                "erc": "ERC721",      # <---- This indicates which ERC
                "type": "throw",         # <---- This indicates rule type
                "rule": " throw if _owner is the zero address",       # <---- This indicates the violated natural language rule.
                "contract": "TicketOwnership",                        # <---- This indicates contract that the function belongs to (if child contract overrides parent contract, this will be the child contract).
                "fn_interface": "function balanceOf(address _owner) external view returns (uint256)",     # <---- This indicates which function has this violation
                "rid": 1,                   # <---- This indicates the rule ID, user can ignore this.
                "tags": [                   # <---- This just for debugging, user can ignore this.
                    "function"
                ]
            },
            ... (Ignored other violations for demonstration purpose)
            ## !!!!!! This is the violation highlighed in the paper Figure 2 !!!!!! ##
            {
                "erc": "ERC721",  
                "type": "throw",
                "rule": " throw if `msg.sender` is not the current owner, an authorized operator, or the approved address for this NFT",
                "contract": "TicketOwnership",
                "fn_interface": "function transferFrom(address _from, address _to, uint256 _tokenId) external payable",
                "rid": 21,
                "tags": [
                    "function"
                ]
            },
            ... (Ignored other violations for demonstration purpose)
        ]
    }
}
```

### Audit Figure 9
#### Audit a smart contract at benchmark/large/MyERC1155Token-0x6482e7f6.sol
```bash
$ ./x audit benchmark/large/MyERC1155Token-0x6482e7f6.sol --out-dir MyERC1155Token
```

#### Output file is located at MyERC1155Token/MyERC1155Token-0x6482e7f6.json
- All demonstrated violations mentioned in paper's figure 9
```json
{
    "sol_file": "benchmark/large/MyERC1155Token-0x6482e7f6.sol",
    "contract": {
        "MyERC1155Token": [
           ... (Ignored other violations for demonstration purpose)
            {
                "erc": "ERC1155",
                "type": "throw",
                "rule": " throw if `_to` is the zero address",
                "contract": "MyERC1155Token",
                "fn_interface": "function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external",
                "rid": 0,
                "tags": [
                    "function"
                ]
            },
            {
                "erc": "ERC1155",
                "type": "throw",
                "rule": " throw if balance of holder for token `_id` is lower than the `_value` sent",
                "contract": "MyERC1155Token",
                "fn_interface": "function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external",
                "rid": 1,
                "tags": [
                    "function"
                ]
            },
            {
                "erc": "ERC1155",
                "type": "emit",
                "rule": "emit '['TransferSingle']' if the balance change is reflected after the transfer",
                "contract": "MyERC1155Token",
                "fn_interface": "function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external",
                "rid": 3,
                "tags": [
                    "function"
                ]
            },
            {
                "erc": "ERC1155",
                "type": "call",
                "rule": "call onERC1155Received if _to is a smart contract (e.g. code size > 0)",
                "contract": "MyERC1155Token",
                "fn_interface": "function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external",
                "rid": 4,
                "tags": [
                    "function"
                ]
            },
            ... (Ignored other violations for demonstration purpose)
        ]
    }
}
```

### Audit Figure 10
#### Audit a smart contract at benchmark/large/0x74Ebcf0426DF50604ec5648D1a0681ed530908F7.sol
```bash
$ ./x audit benchmark/large/0x74Ebcf0426DF50604ec5648D1a0681ed530908F7.sol --out-dir 0x74Ebc
```

#### Output file is located at 0x74Ebc/0x74Ebcf0426DF50604ec5648D1a0681ed530908F7.json
```json
{
    "sol_file": "benchmark/large/0x74Ebcf0426DF50604ec5648D1a0681ed530908F7.sol",
    "contract": {
        "MintPassGELO": [
            {
                "erc": "ERC1155",
                "type": "emit",
                "rule": "emit 'TransferSingle'",
                "contract": "MintPassGELO",
                "fn_interface": "airDrop(address,address[],uint256,uint256) returns()",
                "rid": 15,
                "tags": [
                    "function"
                ]
            }
        ]
    }
}
```

### Audit another contract with high-severity violation
#### Audit a smart contract at benchmark/large/ArnoldSailormoonegger-0x294d7be2.sol
```bash
$ ./x audit benchmark/large/ArnoldSailormoonegger-0x294d7be2.sol --out-dir arnold
```

#### Output file is located at arnold/ArnoldSailormoonegger-0x294d7be2.json
```json
{
    "sol_file": "benchmark/large/ArnoldSailormoonegger-0x294d7be2.sol",
    "contract": {
        "ArnoldSailormoonegger": [
            {
                "erc": "20",
                "type": "interface",
                "rule": "function approve(address _spender, uint256 _value) public returns (bool success)", 
                "contract": "ArnoldSailormoonegger",
                "fn_interface": null,
                "rid": 7,
                "tags": [
                    "no_function"
                ]
            },
            {
                "erc": "20",
                "type": "interface",
                "rule": "event Approval(address indexed _owner, address indexed _spender, uint256 _value)",
                "contract": "ArnoldSailormoonegger",
                "fn_interface": null,
                "rid": 1,
                "tags": [
                    "event"
                ]
            },
            {
                "erc": "20",
                "type": "throw",
                "rule": " throw if the _from account has not deliberately authorized the sender of the message via some mechanism",
                "contract": "ArnoldSailormoonegger",
                "fn_interface": "function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)",
                "rid": 11,
                "tags": [
                    "function"
                ]
            }
        ]
    }
}
```

### ERC Rule Extraction
```bash
# Extract and translate an ERC documentation
# This requires the OPENAI API Token, which can be created from https://platform.openai.com/settings/organization/api-keys
# export OPENAI_API_KEY=xxx
$ ./x erc erc/ERC20 --out-dir ext_erc
# This command will create json file(s) under ext_erc folder.
```

#### Output file
```json
{
    "functions": [ 
      {
            "def": "function name() public view returns (string)",        # <---- Function interface
            "raw_rules": "...",                                           # <---- Function description/comment
            "format": {                                                   # <---- Function attributes, including arguments(if any), return value(if any)
                "name": "name",                                                       
                "arg_types": [],
                "optional": null,
                "view": true,
                "pure": false,
                "payable": false,
                "return_type": {
                    "type": "string"
                }
            },
            ... (Ignored other debug fields for demonstration purpose)
        },
      ... (Ignored other elements for demonstration purpose)
     ],
    "events": [
      {
            "def": "event Transfer(address indexed _from, address indexed _to, uint256 _value)",      # <---- Event interface
            "raw_rules": "...",                                       # <---- Event description/comment
            "format": {                                        # <---- Event attributes, including arguments(if any)
                "name": "Transfer",
                "arg_types": [
                    {
                        "name": "_from",
                        "type": "address",
                        "indexed": true
                    },
                    {
                        "name": "_to",
                        "type": "address",
                        "indexed": true
                    },
                    {
                        "name": "_value",
                        "type": "uint256",
                        "indexed": false
                    }
                ]
            },
            ... (Ignored other debug fields for demonstration purpose)
      }

      ... (Ignored other elements for demonstration purpose)
    ],
    "rule": [
      ... (Ignored other elements for demonstration purpose)
      {
            "rule": " throw if the message caller's account balance does not have enough tokens to spend",      # <---- natural langauge rule
            "type": "throw",           # <---- rule's type
            "interface": "function transfer(address _to, uint256 _value) public returns (bool success)",        # <---- rule's target(it can be either a function or a event)
            "sym": {
                "ThrowVerify": {                                                      # <---- JSON(AST) format of DSL rule
                    "type": "ThrowVerify",
                    "cond": {
                        "type": "CompCondition",
                        "left": {
                            "type": "StateVarSelector",
                            "anchor_fn": "balanceOf",
                            "keys": [
                                {
                                    "type": "MsgSenderSelector"
                                }
                            ]
                        },
                        "right": {
                            "type": "FuncParamSelector",
                            "index": 1
                        },
                        "op": "lt"
                    },
                    "op": "throw"
                }
            },
      }
      ... (Ignored other elements for demonstration purpose)
    ]
}
```

## Repository Structure

### /
`x` is an easy-to-use executable entrypoint for `python/main.py`

### /py
- `main.py`: CLI entrypoint
- `audit`: Code related to CLI command 'audit'
  - `process.py`: Entrypoint of auditing smart contract with ERC documentation
- `erc`: Code related to CLI command 'erc'
  - `process.py`: Entrypoing of processing ERC documentation
  - `pipeline.py`: Pipeline manager for processing ERC documentation
  - `pipelines`: Folder contains ERC extraction and translation
    - `extract_rule.py`: ERC extraction
    - `gen_sym.py`: ERC translation
- `llm`: Large langauge model related utilities (API Client, response parser)
- `sol`: Solidity related code
  - `sym.py`: Self-made symbolic execution engine for solidity

All the smart contract source code used in evaluation is in `benchmark`:
- `benchmark/baseline`: 40 contracts: 30 ERC20, 5 ERC721, and 5 ERC1155. Randomly select ERC20 contracts audited by the Ethereum Commonwealth Security Department (ECSD), an expert group that reviews GitHub-submitted audit requests and publish their audit results on GitHub, others from ERCx.
- `benchmark/large`: 4,000 unique contracts for evaluation, including 3,400 ERC20, 500 ERC721, and 100 ERC1155 contracts. The contracts are randomly sampled from etherscan.io and polygonscan.com.

## 1. Introduction (Section 1)

Lines 35 - 36, Figure 1's original source code can be found at: `~/symgpt/benchmark/large/0xa47a731dcd4267893c5c210056476d404088521a.sol`, the contract declaration can be found at line 2028.

## 2. Background (Section 2)

Lines 208 - 218, What an ERC721 specifies (motivation, required APIs/events, and per-function rules in text/comments), can be found at :`~/symgpt/erc/ERC721`, the rules for mentioned function `transferFrom` can be found at line 92 - line 102, rules for function `safeTransferFrom` can be found at line 70 - line 82.

## 3. Empirical Study on ERC Rules (Section 3)

Lines 278 - 279,  ERC20 / ERC721 / ERC1155 can be found at `~/symgpt/erc/ERC20`, `~/symgpt/erc/ERC721`, `~/symgpt/erc/ERC1155`.

Lines 282-284, the referenced data can be found at `https://etherscan.io/chart/deployed-contracts` and `https://polygonscan.com/chart/deployed-contracts`. 

Lines 284 - 289, identified rules can be found at google sheet `https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=0#gid=0`'s Table 1, column E. The total number of rules, 132, can be found at column E, row 143.
32 from ERC20 can be found at column B, row 147. 60 from ERC721 can be found at column B, row 148. 40 from ERC1155 can be found at column B, row 149.
 

### 3.1 Rule Content (What)


All following columns and rows are referenced from Google Sheet: [Table 1](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=0#gid=0).

Lines 324 - 325, "20 rules involve checking a condition.." 20 rules can be found at column AE, row 139.

Lines 326 - 327, "10 rules pertain to the operator.." 10 rules can be found at column Y, row 139.

Lines 328 - 329, "Additionally, three rules
address whether the token.." 3 rules can be found at column Z, row 139.

Lines 330 - 331, "The remaining
11 rules focus on transfer.." 11 rules can be found at column AA, row 139.

Lines 335 - 336, "First, 24 rules
specify how functions should.." 24 rules can be found at column K, row 139.

Lines 339 - 340, "Second, 12 rules address how to validate.." 12 rules can be found at column AC, row 139.

Lines 341 - 342, "Third, two rules explicitly mandate the associated.." 2 rules can be found at row 117 and row 124.

Lines 358 - 359, "Fourth, three rules specify how to update particular
variables.." 3 rules can be found at column AM, row 139.

Lines 361 - 362, "The remaining rule is from ERC1155.." 1 rule can be found at row 126.

Lines 364 - 365, "The three ERCs mandate 33 public functions...", 33 can be found at column I, row 139. 

Lines 367 - 368, "In total, 33 rules govern logging: 24 specify when to emit events, eight further define required parameters, and nine
address event declarations." 24 can be found at column AI, row 139 + column AJ, row 139. 9 can be found at column AH, row 139. 33 is the sum of them.

Lines 372 - 378, "Among the 132 rules, 106 rules are confined to a single function ... Moreover nine rules pertain to event declararions ... The valid scopes of the remaining 17 cases encompass the entire contract." 9 rules can be found at column AH, row 139. 17 cases can eb found at column AO, row 139. 106 is the total number of rules (132) minus (9 + 17).

### 3.2 Violation Impact (Why)

All following columns and rows are referenced from Google Sheet: [Table 1](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=0#gid=0).

Lines 386 - 421, the number of high, medium and low rules can be found at row 139 at column P, column Q, and column R. 

### 3.3 Linguistic Patterns (How)

All following columns and rows are referenced from Google Sheet: [Table 2](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=764513459#gid=764513459).

Lines 426 - 438 and Table 2, the number of each linguistic patterns can be found at row 137, from column F to column Q. The sum 90 can be found at row 138, column F.

## 4. The Design of SymGPT (Section 4)
### 4.1 ERC Rule Extraction

Line 528, "Figure 4 illustrates the prompt template..." refers to line 19 at `~/symgpt/py/erc/pipelines/extract_rule.py`.

### 4.2 ERC Rule Translation

Line 563, "Figure 5 shows the grammar ..." The grammar refers to line 28 at `~/symgpt/py/sol/sym.py`.

Lines 611 - 612, "For example, Figure 6 shows the rule violated in Figure 1.." refers to line 1625 at `~/symgpt/erc/build/ERC721_ERC721.json`.

Lines 654 - 655, "Figure 7 shows the prompt template." refers to line 26 at `~/symgpt/py/erc/pipelines/gen_sym.py`.

### 4.3 Synthesizing Violation Constraints

Lines  662 - 732 refers to the line 615 and line 860 at `~/symgpt/py/sol/sym.py`.

### 4.4 Static Analysis and Symbolic Execution

The engine refers to the line 791 at `~/symgpt/py/sol/sym.py`.


## 5. Evaluation (Section 5)
### 5.1 Effectiveness of SymGPT

Script `~/symgpt/scripts/run-large.sh` can trigger the SymGPT on 4,000 contracts. This script may run over 12 hours, depends on the CPU and memory.

The result is collected in Google Sheet: [Table 5](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1200431584#gid=1200431584). All following columns and rows are referenced from this table as well.

Lines 803 - 804, " a large dataset of 4,000 unique contracts ", these contracts are located at `~/symgpt/benchmark/large`.
Lines 823 - 825, "SymGPT detects 5,783 ERC rule violations while reporting only 122 false postivies..", 5,783 refers to row 5907, column G and 122 refers to row 5907, column H.
Lines 830 - 831, "True Positives. Among the 5,783 detected ERC rule violations, 1,375 have a high security impact,
3,720 have a medium security impact, and 688 have a low security impact." 1,375 refers to the column D, row 5909. 3,720 refers to the column D, row 5910. 688 refers to the column D, row 5911.

Line 5970, An ERC1155 contract contains four high-security impact violations. Original source code: `benchmark/large/MyERC1155Token-0x6482e7f6.sol`, this violation can be quickly checked by command `./x audit benchmark/large/MyERC1155Token-0x6482e7f6.sol`.


### 5.2 Comparison with Baselines

The result is collected in Google Sheet: [Table 6](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1207380795#gid=1207380795). All following columns and rows are referenced from this table as well.

Lines 991 - 992, SymGPT, "As shown in Table6, SymGPT detects 157 out of the 159 violations, .." TP(157) refers to the row 219, column K. 159 refers to the row 219, column E. Its FP/FN refers to the row 219, column L and column M.

Lines 996 - 997, Slither, "detects the highest number of violations among all baselines,including 26 cases ..." highest number TP(39) refers to the row 219, column O. 26 refers to the row 228, column O. Its FP/FN refers to row 219, column P, and column Q.

Lines 997 - 998, ",and 13 event-related..." 13 refers to the row 229, column O. 

Lines 1003 - 1008, AChecker, paper's table 6's TP/FP/FN refers to the row 219, column S, column T, and column U.

Lines 1008 - 1017, ZepScope, paper's table 6's TP/FP/FN refers to the row 219, column W, column X, and column Y.

Lines 1017 - 1020, NFTGuard, paper's table 6's TP/FP/FN refers to the row 219, column AA, column AB, and column AC.

Lines 1020 - 1023, Mythril, paper's table 6's TP/FP/FN refers to the row 219, column AE, column AF, and column AG.

Lines 1023 - 1043, ERCx, paper's table 6's TP/FP/FN refers to the row 219, column AI, column AJ, and column AK.

Lines 1043 - 1049, ECSD, paper's table 6's P/FP/FN refers to the row 219, column AM, column AN, and column AO.

Below is the detailed instruction to run the above tools on baseline dataset:


SymGPT
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
# Output files are in the ./local/baseline
$ ./scripts/run-baseline.sh
```
Slither
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
# Output files are in the ./local/sce
$ ./scripts/run-sce.sh
```
AChecker
```bash
$ cd ~/symgpt
# (Optional) AChecker requires binary code of contract, we have built them for you at benchmark/baseline_bin
$ ./scripts/compile-all-sol.sh
$ cd third_party/AChecker
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install -r requirements.txt
$ cd ~/symgpt
# Output files are in the ./local/achecker
$ ./scripts/run-achecker.sh
```
ZepScope:
```bash
$ cd ~/symgpt/ZepScope-Code
$ python3 -m venv .venv
$ source .venv/bin/activate
$ pip install -r requirements.txt
$ ./run.sh
```
NFTGuard:
```bash
# This tool requires Docker, this tool provides official docker image.
# The script will automatically run the tool for each file in the baseline
$ python3 ./run-nftguard.py
```
Mythril:
```bash
# This tool requires Docker, this tool provides official docker image.
# Output files are in the ./local/mythril 
$ ./scripts/run-mythril.sh
```
ERCx:

This tool can only be used through online webpage: https://ercx.runtimeverification.com/

ECSD Auditing Service:
| Contract File | Audit URL |
|---------------|-----------|
| benchmark/baseline/KuCoin.sol | https://github.com/EthereumCommonwealth/Auditing/issues/341 |
| benchmark/baseline/mxm.sol | https://github.com/EthereumCommonwealth/Auditing/issues/330 |
| benchmark/baseline/dai.sol | https://github.com/EthereumCommonwealth/Auditing/issues/340 |
| benchmark/baseline/KIMEX.sol | https://github.com/EthereumCommonwealth/Auditing/issues/130 |
| benchmark/baseline/EZOToken.sol | https://github.com/EthereumCommonwealth/Auditing/issues/422 |
| benchmark/baseline/CMBToken.sol | https://github.com/EthereumCommonwealth/Auditing/issues/336 |
| benchmark/baseline/LUTOKEN.sol | https://github.com/EthereumCommonwealth/Auditing/issues/248 |
| benchmark/baseline/PKG.sol | https://github.com/EthereumCommonwealth/Auditing/issues/349 |
| benchmark/baseline/aoa.sol | https://github.com/EthereumCommonwealth/Auditing/issues/322 |
| benchmark/baseline/huobi.sol | https://github.com/EthereumCommonwealth/Auditing/issues/309 |
| benchmark/baseline/KINGSGLOBAL.sol | https://github.com/EthereumCommonwealth/Auditing/issues/279 |
| benchmark/baseline/idex.sol | https://github.com/EthereumCommonwealth/Auditing/issues/246 |
| benchmark/baseline/axpire.sol | https://github.com/EthereumCommonwealth/Auditing/issues/238 |
| benchmark/baseline/xeuro.sol | https://github.com/EthereumCommonwealth/Auditing/issues/218 |
| benchmark/baseline/zrx.sol | https://github.com/EthereumCommonwealth/Auditing/issues/211 |
| benchmark/baseline/iostoken.sol | https://github.com/EthereumCommonwealth/Auditing/issues/196 |
| benchmark/baseline/egypt.sol | https://github.com/EthereumCommonwealth/Auditing/issues/194 |
| benchmark/baseline/bitcoinsvgold.sol | https://github.com/EthereumCommonwealth/Auditing/issues/193 |
| benchmark/baseline/omg.sol | https://github.com/EthereumCommonwealth/Auditing/issues/192 |
| benchmark/baseline/battoken.sol | https://github.com/EthereumCommonwealth/Auditing/issues/191 |
| benchmark/baseline/mkr.sol | https://github.com/EthereumCommonwealth/Auditing/issues/178 |
| benchmark/baseline/bnb.sol | https://github.com/EthereumCommonwealth/Auditing/issues/177 |
| benchmark/baseline/xn35.sol | https://github.com/EthereumCommonwealth/Auditing/issues/174 |
| benchmark/baseline/gencoin.sol | https://github.com/EthereumCommonwealth/Auditing/issues/164 |
| benchmark/baseline/wit.sol | https://github.com/EthereumCommonwealth/Auditing/issues/155 |
| benchmark/baseline/jntr.sol | https://github.com/EthereumCommonwealth/Auditing/issues/144 |
| benchmark/baseline/silkroad.sol | https://github.com/EthereumCommonwealth/Auditing/issues/122 |
| benchmark/baseline/organicco.sol | https://github.com/EthereumCommonwealth/Auditing/issues/119 |
| benchmark/baseline/pandai.sol | https://github.com/EthereumCommonwealth/Auditing/issues/684 |
| benchmark/baseline/husky.sol | https://github.com/EthereumCommonwealth/Auditing/issues/501 |
	

### 5.3 Rationality of SymGPT’s Components

The result is collected in Google Sheet: [Figure 11](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1918933567#gid=1918933567). All following columns and rows are referenced from this table as well.

Lines 1089 - 1090, Circle(1) Without Rule Extraction, TP/FP/FN refers to the row 219, column F, column G, and column H.
Lines 1090 - 1903, Circle(2) Without Rule Translation, TP/FP/FN refers to the row 219, column J, column K, and column L.
Lines 1093 - 1096, Circle(3) Without Constraint Generation, TP/FP/FN refers to the row 219, column N, column O, and column P.
Lines 1096 - 1099, Circle(4) Without Symbolic Execution, TP/FP/FN refers to the row 219, column R, column S, and column T.
Lines 1099 - 1110, GPT 5 TP/FP/FN refers to the row 219, column V, column W, and column X.
Lines 1110 - 1113, GPT 4 TP/FP/FN refers to the row 219, column Z, column AA, and column AB.

SymGPT and SymGPT(GPT-4) results are identical, the results are mentioned in Google Sheet: [Table 6](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1207380795#gid=1207380795), TP(157) refers to the TP at row 219, column K. Its FP/FN refers to the row 219, column L and column M.

Figure 11 can be draw from `~/symgpt/scripts/figure11.ipynb`.

Following are referenced scripts to run the results:

SymGPT
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
# Output files are in the ./local/baseline
$ ./scripts/run-baseline.sh
```

SymGPT(GPT-4)
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
$ mv erc/build erc/build_backup && mv erc/buildg4 erc/build
# Output files are in the ./local/baseline
$ ./scripts/run-baseline.sh
$ mv erc/build erc/buildg4  && mv erc/build_backup erc/build 
```

W.O. E
```bash
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ python scripts/woe.py
```
W.O. T
```bash
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ python scripts/wot.py
```
W.O. G
```bash
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ python scripts/wog.py
```
W.O. S
```bash
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ ./scripts/wos.sh
```
GPT-4
```bash
# Note: manually change py/sol/sym.py:2287 from "model="gpt-5"" to model="gpt-4"
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ ./scripts/run-gpt4.sh
```

GPT-5
```bash
$ export OPENAI_API_KEY=xxx
$ source .venv/bin/activate
$ ./scripts/run-gpt5.sh
```

### 5.4 Generality of SymGPT

Script to run for ERC3525: 
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
# Output files are in the ./local/sce
$ ./scripts/run-erc3525.sh
```

Script to run for ERC4907:
```bash
$ cd ~/symgpt
# Make sure in the virtual environment
$ source .venv/bin/activate
# Output files are in the ./local/sce
$ ./scripts/run-erc4907.sh
```

