###View Stamp Replication

Key Contributions/Interesting ideas
2) Describes Protocol for repliaction ,leader changes and group changes.
1) Recovery without persistant state
3) Quorum interesection property used to stay upto date

Notes

1) Requires 2*f+1 groups to survive, f failures.
2) Relies on the quorum intersection property for correctness.
3) Order of significance (descending)
	1) Epoch -> The group of replicas(epoch increase after reconfiguration)
	2) View  -> The leader in the group(view increases as the leaders die and new leaders are elected)
	3) request id 
4) Leader serves as primary and the others serve as backups
5) logs are used for recovery.


Normal Operation


1) Primary on recieving a request sends <PREPARE> messages to followers and commits only 
when a majority <ACCEPT> . Then it commits locally and sends <commit OK>
2) Backups monitor the primary if it is dead start view change.

View Change


1) A back up replica sends <STARTVIEW> to all replicas.When f+1 replicas reply with <DOVIEW>.
Sends <STARTVIEW>  and starts accepting request.

Recovery


A recovering node contacts all peers, waits till it gets f+1 replies ,takes the maximum of 
the log and resumes normal operation


Reconfiguration Protocol


1) Primary receives request and sends <PREPARE>
2) On receiving majority <PREPARE_OK>
3) commits request and send <START EPOCH>
4) When a replica which is present in the final group receives it
bring itself upto date and sends <EPOCH STARTED> to the replaced replica
5) When a replcaed replica receives f+1 started, it kills itself

Correctness of normal operation amidst failure
1) A committed operation is never lost
2) An operation for which a prepare message was sent , but not committed might be preserved during view change

Engineering details
1) Checkpointing used to limit the size of the log.
2) Merkle tree and copy on write used to keep only changes
3) Batch processing of requests
