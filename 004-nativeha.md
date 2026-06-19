# Demonstrate Native HA

This section starts the demonstration portion of the IBM MQ nativeHA and CRR functionality. This unit focuses on the Native HA environment. So you will mainly work on the SITE1 environment with host11, host12 and host13 as the main participant.

## Understanding native HA

To understand the native HA and CRR environment, the command to check that is `dspmq -o nativeha -g -x -m qmgr` on which
- the `-o` displays only information about native HA and CRR
- the `-x` displays the local Native HA members
- the `-g` displays local and remote group information
- the `-m` select which queue manager to report from

From the bastion, you can run the script [scripts/4-1-checkhacrr.sh](scripts/4-1-checkhacrr.sh)

The following is a sample output:
![images/004-01-ha-live.png](images/004-01-ha-live.png)
![images/004-02-ha-recovery.png](images/004-02-ha-recovery.png)

In the Live side, the command is run from the first instance arbitrarily. There is no specific preference on which instance will be active. 

- The first line is the short information of the current Queue Manager in the specific host. 
- The `INSTANCE` lines are the local native HA group of Queue Manager (from option `-x`). The important information are:
    - the individual `ROLE`s (Active, Leader, Replica) - only the Active instance is accepting client connection
    - The `CONNACTV` indicates whether the connection is active on 9414
    - The `INSYNC` shows whether the group member is synchronized. If so the `BACKLOG` should be 0 and the `ACKLSN` should all be the same.
- The GRPNAME lines show the status of the interconnected groups (from option `-g`). The important information are:
    - the `GRPROLE` of Live or Recovery
    - The local group is indicated in the QMNAME line on the top, and should have a `GRSTATUS` of Normal
    - The remote group should have the `INSYNC` status of yes
    - When every pieces are in sync, then all the `RECOVLSN` should be the same and also matches with `ACKLSN` of the individual instances
- Note that the timestamp of the timing is also presented, but the LSN (Log Sequence Number) are more accurate on identifying the status.

## Demonstrating automatic failover

Follow these procedure:

1. Keep a ssh session showing dspmq output using a watch command:

    ``` bash
    ssh #{host11} watch -n 5 dspmq -o nativeha -g -x
    ```

2. in another ssh session run the mq_message_sender program to launch a raandomized message to the MQ 

    ``` bash
    bash scripts/mq_message_sender.sh
    ```

3. Run these command to switch the active MQ server as you watch the changes in the other `dspmq` output and the message sender window:

    ``` bash
    ssh <activemqhost> sudo systemctl restart mqmonitor@<qmgr>
    ```

    note - if you are lazy to see which host is actually active, you can run the following script
    
    ``` bash
    bash scripts/4-2-haswap.sh
    ```

See the following 

