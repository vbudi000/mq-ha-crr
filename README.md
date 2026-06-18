# IBM MQ nativeHA and Cross Region Replication 

This Proof of Concept guide is written to allow you to demonstrate this MQ feature in a VM based environment. 
The document is split into the following sections:

1. [Environment preparation](001-env.md) 
2. [Installation of MQ](002-install.md)
3. [Create Native HA CRR environment](003-createQM.md)
4. [Demonstrate native HA failover](004-nativeHA.md)
5. [Demonstrate Planned CRR failover](005-crr-planned.md)
6. [Demonstrated Unplanned Failover and Split brain recovery](006-crr-unplanned.md)


Note that the first 3 are setup and installation, while the last 3 is demonstration steps. If you ever messed up these steps, delete the Queue Managers and redo the creation of Native HA CRR environment (step 3)

Demonstration video of nativeHA and CRR planned failover is provided in <>.

Change history:

This document is created on June 2026 on IBM MQ 9.4.5
The lab is initially run on RedHat Enterprise Linux VMs V9

