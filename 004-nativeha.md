# Demonstrate Native HA

This section begins the demonstration portion of IBM MQ Native HA and CRR functionality. This unit focuses on the Native HA environment, so you will primarily work with the SITE1 environment — hosts `host11`, `host12`, and `host13`.

- [Native HA Status](#understanding-native-ha)
- [Demonstrate Native HA](#demonstrating-automatic-failover)

## Understanding Native HA

To inspect the Native HA and CRR environment, use the command `dspmq -o nativeha -g -x -m <qmgr>`:

- `-o` — displays only Native HA and CRR information
- `-x` — displays the local Native HA members
- `-g` — displays local and remote group information
- `-m` — selects which Queue Manager to report on

From the bastion, you can run the script [scripts/4-1-checkhacrr.sh](scripts/4-1-checkhacrr.sh).

The following are sample outputs:

![images/004-01-ha-live.png](images/004-01-ha-live.png)
![images/004-02-ha-recovery.png](images/004-02-ha-recovery.png)

In the Live site, the command can be run from any instance — there is no fixed preference for which instance will be active.

- The **first line** shows a brief status of the Queue Manager on the local host.
- The **`INSTANCE` lines** show the members of the local Native HA group (from `-x`). Key fields:
    - `ROLE` (Active, Leader, Replica) — only the Active instance accepts client connections.
    - `CONNACTV` — indicates whether the replication connection on port 9414 is active.
    - `INSYNC` — shows whether the member is synchronised. When in sync, `BACKLOG` should be `0` and all `ACKLSN` values should match.
- The **`GRPNAME` lines** show the status of interconnected groups (from `-g`). Key fields:
    - `GRPROLE` — either `Live` or `Recovery`.
    - The local group appears in the `QMNAME` line at the top and should have a `GRSTATUS` of `Normal`.
    - The remote group should show `INSYNC` as `Yes`.
    - When everything is in sync, all `RECOVLSN` values should match the `ACKLSN` of the individual instances.
- LSN (Log Sequence Number) values are more reliable than timestamps for determining synchronisation status.

## Demonstrating Automatic Failover

Follow this procedure:

1. Open three terminal (SSH) sessions to the bastion host.

2. In the first session, SSH to one of the Live Queue Manager hosts (assuming SITE1 is Live) and continuously display the `dspmq` output:

    ``` bash
    ssh ${host11}
    watch -n 5 dspmq -o nativeha -g -x
    ```

3. In the second session, run the `mq_message_sender.sh` script to send randomised messages with timestamps to MQ:

    ``` bash
    cp scripts/mq_message_sender.sh /tmp
    su - mqm /tmp/mq_message_sender.sh
    ```

4. In the third session, trigger an active Queue Manager failover and watch the changes in the other two windows:

    ``` bash
    ssh <activemqhost> sudo systemctl restart mqmonitor@<qmgr>
    ```

    If you prefer not to look up which host is currently active, use the following script instead:

    ``` bash
    bash scripts/4-2-haswap.sh
    ```

5. As you cycle through active Queue Manager instances, the `watch` output will show the Active role moving between members. The previously Active instance becomes a Replica after restarting. The message sender will report brief failures, but the gap between successful messages should be less than 2 seconds.

    ![images/004-03-haswap.png](images/004-03-haswap.png)

    In the highlighted section, the time between successful messages is approximately 1.7 seconds.
