# Day 22 – Decentralized Lottery (Chainlink VRF)

This project implements a simple decentralized lottery using Chainlink VRF for provably fair randomness. The owner can open the lottery, accept entries, request a random number from Chainlink, and automatically select a winner.

---

## 1. Overview

The contract uses Chainlink VRF V2 to generate a secure random number.
Players enter by paying the entry fee.
When the lottery ends, a VRF request is sent and the winner is chosen in the VRF callback.

---

## 2. Foundry Commands Used

These were the main commands during setup:

```
forge init
forge install smartcontractkit/chainlink-brownie-contracts --commit
forge build
forge clean
```

Git commands used for the final upload:

```
git init
git add .
git commit -m "Day 22: Decentralized Lottery"
git branch -M main
git remote add origin <repo-url>
git push -u origin main
```

---

## 3. Short Source Code Explanation

* The contract imports VRFConsumerBaseV2 and VRFCoordinatorV2Interface from Chainlink.
* Lottery states: OPEN, CLOSED, CALCULATING.
* Players join using the `enter()` function.
* Owner starts and ends the lottery.
* `endLottery()` sends a randomness request to Chainlink.
* `fulfillRandomWords()` receives the random number, selects the winner, resets players, and transfers the funds.

---

## 4. Foundry Configuration

The only custom configuration added in `foundry.toml` is the remapping:

```
chainlink-brownie-contracts/=lib/chainlink-brownie-contracts/contracts/
```

This allows Solidity imports from the Chainlink library.

---

## 5. Why the Chainlink Library Folder Was Not Pushed

The `lib/chainlink-brownie-contracts` folder contains tens of thousands of files.
Including it caused:

* Git submodule errors
* Nested `.git` folders
* Very large commits
* Failed pushes

The correct approach is to ignore the `lib/` folder and let users reinstall dependencies using:

```
forge install smartcontractkit/chainlink-brownie-contracts
```

---

## 6. Why a New Repository Was Created

The old repository had corrupted submodules and too many unnecessary library files.
Even after cleanup, Git continued to show conflicts and failed to add files.
Creating a new clean Foundry project was the simplest and most reliable solution.

New repo link:
[https://github.com/Deepakkumar2206/Day22_DecentralizedLottery](https://github.com/Deepakkumar2206/Day22_DecentralizedLottery)

Official 30-days repo link:
[https://github.com/Deepakkumar2206/30-days-of-solidity-deepak](https://github.com/Deepakkumar2206/30-days-of-solidity-deepak)

---

# End of the Project.
