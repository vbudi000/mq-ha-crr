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

```
```

The Live group and the Recovery group information 

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

3. Run these command to switch the active MQ server as you watch the changes in the other 2 command windows:

    ``` bash
    ssh <activemqhost> sudo systemctl restart mqmonitor@<qmgr>
    ```

See the following 

