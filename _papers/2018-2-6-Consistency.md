---
layout: default
title: Linearizability vs Sequential Consistency
tags:
- Computer Science 
---

##Linearizability

1. Defined from the view point of clients.
2. The history consists of Invocations and Responses operations(from different clients)
on an object(which is distributed) ordered according to time.
3. There exists a sequential history of operations (grouping of respective invocations and response)
which result in the same result for respective responses as if the operations happenned sequentially.
4. Invocations that happenned after responses cannot be reordered in the above sequential history.
5. Sequential history follows the definition of the object

##Sequential Consistency

1. View point of server
2. Operations on each server machine appear to happen in some global order.
3. Local order of operations is followed in the global order.(Kind of redundant)