ZooKeeper: Wait-free coordination for Internet-scale systems
(published USENIX:2010)

**Random Notes**
Prof:Marcos Serfani: wrote the Zookeeper atomica protocol, which used to maintain consensus
in zookeeper


**Main Contribution**

1. Provides an abstraction on which distributed primitives such as leader election,
distributed lock service can be built.
2. Uses active sessions for co-ordination.
3. eg. of where this abstraction is used (Katta: group membership, leader election, 
configuration management)
4. Provides Recipes using the stated abstraction to build complex co-ordination mechanism.
5. Fuzzy Snapshot with idempotent transactions.
**Key Ideas of the paper**

***Abstraction***
1. Zookeeper stores data in the form of a data. Data(Nodes) can be accessed via the path.
2. Clients use zookeeper through a clientside library.
2. Clients establish a session through which requests are sent.
2. Sessions are maintained by sending hearbeats.
2. Nodes have a sequential flag which is monotonically increasing over a parents previously created children
3. Zookeeper implements watches through which clients recieve update notifications on nodes being watched
, watches are deregistered when the session is closed
4. Guarantees provided: Linearizable writes.
5. Provides a blank operation sync , to bring the local server up-todate.
API:create(path,data,flags) ,delete(path,version) ,exists(path,watch), getChildren(path,watch)


***Examples***

1. Configuration Management: Processes watch a node (z) for configuration changes. They are notified when a leader
makes these changes.
2. Locks: Locks are acquired when a znode is created, destroyed on deleting the znode or if session is terminated.
Other blocked calls are unblocked by notifying them through a watch on this znode.
3. Other examples are barriers and rendezvous.


***Implementation***


1. Upon recieving a write request, atomic broadcast protocol (something like paxos) is used to replicate
changes across server.
2. Updates are logged to a replay log.
3. Each client is connected to a server. Read requests are handled locally, while write requests are
forwarded to leader.
4. Transactions are idempotent and are sent by the leader with a before and after state.
5. Zookeeper takes periodic snapshots.State changes can take place while the snapshot is happenning.
This does not matter as the transactions are idempotent.
6. Client has to periodically send the server something(request/heartbeat) to maintain a session.

**Things I did not understand**
1. Are watches implemented locally. Does the particular local server a node is connected to have to see the commit 
, for the connected to client to be notified.
2. How many active sessions can be implemented ??
3. When a zookeeper client realizes that the server it is connected to has failed and connects to annother server.
Is this treated as a new session?? 