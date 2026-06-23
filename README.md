# IBM MQ Native HA and Cross-Region Replication

This Proof of Concept guide demonstrates the IBM MQ Native HA and Cross-Region Replication (CRR) features in a VM-based environment.

The document is split into the following sections:

1. [Environment Preparation](001-env.md)
2. [Installation of MQ](002-install.md)
3. [Create Native HA CRR Environment](003-createQM.md)
4. [Demonstrate Native HA Failover](004-nativeHA.md)
5. [Demonstrate Planned CRR Failover](005-crr-planned.md)
6. [Demonstrate Unplanned Failover and Split-Brain Recovery](006-crr-unplanned.md)

Sections 1–3 cover setup and installation. Sections 4–6 are demonstration steps. If you make a mistake during setup, delete the Queue Managers and redo step 3 to recreate the Native HA CRR environment.

A demonstration video of Native HA and CRR planned failover is available below:

[![https://youtu.be/LgL4B3wKb0U](https://img.youtube.com/vi/LgL4B3wKb0U/0.jpg)](https://www.youtube.com/watch?v=LgL4B3wKb0U)

## Change History

This document was created in June 2026 for IBM MQ 10.0.0.
The lab was initially run on Red Hat Enterprise Linux 9.8 VMs.
