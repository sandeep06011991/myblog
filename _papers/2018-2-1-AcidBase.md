---
layout: default
title: Mixing Acid and Base Transactions
tags:
- Computer Science 
---

1. Acid Transactions is an transaction abstraction that provides ACID properties with 
all transactions.

2. Base Transactions the transactions are chopped into local operations that can which can 
be intermixed  in anyorder at the local nodes but the ACID properties are ensured by extra 
local code.

3. Converting all transactions to Base is a lot of work as all possible interminglings have
to be accounted for.

4. A base transaction is made up of sub alkaline transactions which are locally atomic

5. Alkaline transactions can intermingle with each other but not ACID transactiosn

6. Acid transactions can intermingle after the complete Base transaction and not its intermediary.

7. This is implemented by locks and specifying rules on which transaction can acquire which kind of alock

##Things I did not understand

1. Sql Isolation levels, Need to comeback after reading this ?

2. How is failure recovery handled ??
