

# The code and results for USENIX 2026 Artifact Evaluation

Paper: SymGPT: Auditing Smart Contracts via Combining Symbolic Execution with Large Language Models

This document is to help users reproduce the results we reported in our submission. It contains the following descriptions:

- [The code and results for USENIX 2026 Artifact Evaluation](#the-code-and-results-for-usenix-2026-artifact-evaluation)
  - [Figure 1: An ERC721 rule violation that can be exploited to steal tokens.](#figure-1-an-erc721-rule-violation-that-can-be-exploited-to-steal-tokens)
  - [Table 1: ERC rules’ content and security impacts](#table-1-erc-rules-content-and-security-impacts)
  - [Table 2: Linguistic patterns](#table-2-linguistic-patterns)
  - [Figure 2: The workflow of SymGPT](#figure-2-the-workflow-of-symgpt)
  - [Figure 3: The ERC rule violated in Figure 1](#figure-3-the-erc-rule-violated-in-figure-1)
  - [Figure 4: EBNF grammar](#figure-4-ebnf-grammar)
  - [Figure 5: The EBNF of the rule violated in Figure 1](#figure-5-the-ebnf-of-the-rule-violated-in-figure-1)
  - [Table 3: Translations from utility functions into constraints](#table-3-translations-from-utility-functions-into-constraints)
  - [Figure 6: Violation constraints for the EBNF rule in Figure 5](#figure-6-violation-constraints-for-the-ebnf-rule-in-figure-5)
  - [Table 4: Step 3 in generating constraints](#table-4-step-3-in-generating-constraints)
  - [Figure 7: A possible input triggering the violation in Figure 1](#figure-7-a-possible-input-triggering-the-violation-in-figure-1)
  - [Table 5: Evaluation results on the large dataset](#table-5-evaluation-results-on-the-large-dataset)
  - [Figure 8: An ERC1155 contract contains four high-security impact violations.](#figure-8-an-erc1155-contract-contains-four-high-security-impact-violations)
  - [Table 6: Evaluation results on the ground-true dataset](#table-6-evaluation-results-on-the-ground-true-dataset)
  - [Figure 9: Contributions of SymGPT's components](#figure-9-contributions-of-symgpts-components)
  - [Environment Setup](#environment-setup)
  - [SymGPT Usage](#symgpt-usage)


SymGPT: Using LLM and symbolic execution to validate whether a smart contract follows the given ERC standard, source code is in `python`. Below is the explanation for its important children file/folders:

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

`x` is an easy-to-use executable entrypoint for `python/main.py`

All the smart contract source code used in evaluation is in `benchmark`:
- `benchmark/baseline`: 40 contracts: 30 ERC20, 5 ERC721, and 5 ERC1155. Randomly select ERC20 contracts audited by the Ethereum Commonwealth Security Department (ECSD), an expert group that reviews GitHub-submitted audit requests and publish their audit results on GitHub, others from ERCx.
- `benchmark/large`: 4,000 unique contracts for evaluation, including 3,400 ERC20, 500 ERC721, and 100 ERC1155 contracts. The contracts are randomly sampled from etherscan.io and polygonscan.com.


## Figure 1: An ERC721 rule violation that can be exploited to steal tokens. 

Original source code: `benchmark/large/0xa47a731dcd4267893c5c210056476d404088521a.sol`

## Table 1: ERC rules’ content and security impacts
Google Sheet: [Table 1](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=0#gid=0)

## Table 2: Linguistic patterns
Google Sheet: [Table 2](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=764513459#gid=764513459)

## Figure 2: The workflow of SymGPT

Auditing: `python/main.py:64`
Erc extraction and translation: `python/main.py:38`

## Figure 3: The ERC rule violated in Figure 1

line 95 at erc/ERC721

## Figure 4: EBNF grammar

The EBNF is for a series of data structures defined at `python/sol/sym.py:28`

## Figure 5: The EBNF of the rule violated in Figure 1

line 1625 at `erc/build/ERC721_ERC721.json`

## Table 3: Translations from utility functions into constraints

Translation is at `python/sol/sym.py:615`

## Figure 6: Violation constraints for the EBNF rule in Figure 5

Same above, translation is at `python/sol/sym.py:615`

## Table 4: Step 3 in generating constraints

Constraints composing logic starts at `python/sol/sym.py:860`

## Figure 7: A possible input triggering the violation in Figure 1


## Table 5: Evaluation results on the large dataset

Google Sheet: [Table 5](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1200431584#gid=1200431584)

## Figure 8: An ERC1155 contract contains four high-security impact violations. 

Original source code: `benchmark/large/MyERC1155Token-0x6482e7f6.sol`


## Table 6: Evaluation results on the ground-true dataset

Google Sheet: [Table 5](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1207380795#gid=1207380795)


## Figure 9: Contributions of SymGPT's components

Google Sheet: [Figure 9](https://docs.google.com/spreadsheets/d/1UmOngXtAwpeSHA3tmHeOLEC0DqH9NWnjhyRTlqcXqNc/edit?gid=1918933567#gid=1918933567)


## Environment Setup
```bash
# Create Python virtual environment
$ python3 -m venv .venv

# Activate the virtual environment in the terminal
$ source .venv/bin/activate

# Install the dependencies
$ pip install -r python/requirements.txt
```

## SymGPT Usage

```bash
# Audit smart contract
$ ./x audit benchmark/large/ArnoldSailormoonegger-0x294d7be2

# Extract and translate an ERC documentation
$ ./x erc erc/ERC20
```