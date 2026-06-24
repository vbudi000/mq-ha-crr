# Unplanned Switch — Disaster Recovery

This section covers two scenarios that arise when a site fails unexpectedly: a straightforward disaster recovery where the surviving site takes over, and a split-brain situation where both sites diverge before reconnecting.

- [Introduction to CRR-Based Disaster Recovery](#crr-based-disaster-recovery)
- [Simulate a Disaster](#disaster)
- [Restore CRR After Recovery](#recovery)
- [Understanding and Resolving Split Brain](#split-brain)

## CRR-Based Disaster Recovery

The following diagram illustrates the key log positions referenced throughout this section:

![images/006-01-LSN.png](images/006-01-LSN.png)

Understanding the LSN values in the diagram is essential before running the exercises:

1. **Normal operation.** SITE1 is Live and SITE2 is the Recovery site. Both are synchronised.
    - `INITLSN` — the log sequence number recorded when the Native HA cluster was last started. It does not change while the Queue Manager is running.
    - `RECOVLSN` — the log sequence number of the most recent confirmed replication point between SITE1 and SITE2. As transactions flow in, this value advances on both sites together.

2. **Disaster strikes.** The network link between SITE1 and SITE2 is severed. SITE1 may continue processing transactions briefly before it detects the loss. The log records between `RECOVLSN` and the final log entry on SITE1 (the "tail") represent transactions that SITE2 never received.

3. **SITE2 restarts as a standalone cluster.** It has its own new `INITLSN` and begins advancing its own `RECOVLSN` independently as new transactions arrive from clients that have reconnected.

4. **Recovery options for SITE1.** Depending on the failure type, one of two paths applies:
    - **SITE1 is recoverable** (e.g., a network partition that has since healed): the log files are still intact. You can read the transactions that SITE2 missed using the `dmpmqlog` command and replay them manually if needed.
    - **SITE1 is unrecoverable** (e.g., hardware failure): the Queue Manager data is lost and SITE1 must be rebuilt from scratch with an empty Queue Manager.

5. **Rejoining SITE1 as a Recovery site.** Regardless of which path is taken, SITE1 must be started with a clean (empty) log before it can join SITE2 as a Recovery group. If SITE1's log still contains transactions that SITE2 never received, MQ will detect the divergence and suspend the replication. Once SITE1 starts clean and connects to SITE2, it will automatically replicate SITE2's full log and synchronise.

6. **Restoring normal operation.** After SITE1 is synchronised as a Recovery site, a planned site swap (as described in the previous unit) can be used to move the Live role back to SITE1.


## Disaster

Simulate a disaster with the following steps:

1. Stop all message input by terminating the `mq_message_sender.sh` program.

2. Drain the queue by running `mq_message_receiver.sh`.

3. Confirm that the `QDEPTH` of `QUEUE1` is `0` before continuing.

4. Send 5 messages to `QUEUE1`. These will be replicated to SITE2 before we simulate the failure:

    ``` bash
    echo "/tmp/mq_message_sender.sh -m 5" | su - mqm
    ```

5. Shut down all Queue Managers on both sites to simulate a complete outage:

    ``` bash
    ./4-3-sitecmd.sh SITE1 stop
    ./4-3-sitecmd.sh SITE2 stop
    ```

6. Configure SITE2 as the new Live site and start it:

    ``` bash
    ./5-2-siteset.sh SITE2 Live
    ./4-3-sitecmd.sh SITE2 start
    ./rundspmq ${host21}
    ```

7. Observe that `GRPROLE` is `Pending live` and `GRSTATUS` is `Waiting for connection`. This is expected — the Queue Manager was originally configured with a Recovery group (SITE1) and is waiting for it to reconnect. Since SITE1 is gone, you must disable CRR to allow SITE2 to operate as a standalone Live site:

    ``` bash
    ./4-3-sitecmd.sh SITE2 stop
    ./6-1-crrswitch.sh SITE2 No
    ./4-3-sitecmd.sh SITE2 start
    ./rundspmq ${host21}
    ```

    SITE2 should now show `GRPROLE` as `Live` and `GRSTATUS` as `Normal`.

8. Verify that the 5 messages from step 4 are intact, then send 5 more. You should be able to retrieve all 10 messages in total:

    ``` bash
    echo "/tmp/mq_message_sender.sh -m 5" | su - mqm
    echo "/tmp/mq_message_receiver.sh QUEUE1 MYQMGR mqm mqm" | su - mqm
    ```

## Recovery

After the disaster exercise, restore full CRR so that both sites are again providing protection:

1. Stop SITE2 and re-enable CRR replication:

    ``` bash
    ./4-3-sitecmd.sh SITE2 stop
    ./6-1-crrswitch.sh SITE2 Yes
    ./4-3-sitecmd.sh SITE2 start
    ```

2. Configure SITE1 as the Recovery site and start it:

    ``` bash
    ./5-2-siteset.sh SITE1 Recovery
    ./4-3-sitecmd.sh SITE1 start
    ```

3. Check the replication status:

    ``` bash
    ./4-1-checkhacrr.sh
    ```

    Because SITE1 was shut down while SITE2 was operating independently, SITE1's log has diverged. MQ will report the status as `Suspended` or `Partitioned`. SITE1 cannot synchronise from this state — it must be cold-started first.

4. Cold-start SITE1 to discard its diverged log and rebuild the Queue Manager from scratch. MQ will then replicate the full log from SITE2:

    ``` bash
    ./6-0-coldsite.sh SITE1
    ```

    After the cold start, monitor progress:

    - Watch for SITE2 `GRPROLE` to remain `Live` and SITE1 `GRPROLE` to become `Recovery`.
    - Watch SITE1's `INSYNC` and `BACKLOG` — when replication is complete, `INSYNC` becomes `Yes` and `BACKLOG` reaches `0`.

## Split Brain

A split-brain occurs when both sites are running simultaneously but cannot communicate, causing each site to independently advance its log. When they reconnect, MQ detects the divergence and reports `GRSTATUS` as `Partitioned`. Resolving this requires identifying which transactions on the isolated site were never received by the other side.

### Setting Up the Scenario

1. Ensure SITE1 is the Live site. If it is not, swap it back:

    ``` bash
    ./5-1-siteswap.sh
    ```

2. Drain the queue by running `mq_message_receiver.sh` and confirm `QDEPTH` of `QUEUE1` is `0`.

3. Send 5 messages to establish a known replication baseline. Both sites will receive these:

    ``` bash
    echo "/tmp/mq_message_sender.sh -m 5" | su - mqm
    ```

4. Abruptly stop SITE2 to simulate a network failure. SITE1 keeps running but can no longer replicate:

    ``` bash
    ./4-3-sitecmd.sh SITE2 stop
    ```

5. Send 2 more messages to SITE1 while SITE2 is down. These messages are committed on SITE1 but are unknown to SITE2:

    ``` bash
    echo "/tmp/mq_message_sender.sh -m 2" | su - mqm
    ssh $host11 dspmq -o nativeha -g
    ```

    **Save the `RECOVLSN` value from the output.** This is the last log position that SITE2 confirmed before going down. You will use it later to identify the diverged transactions.

6. Stop SITE1 and bring SITE2 back up as a standalone Live site (simulating SITE1 being declared dead and SITE2 being activated independently):

    ``` bash
    ./4-3-sitecmd.sh SITE1 stop
    ./5-2-siteset.sh SITE2 Live
    ./6-1-crrswitch.sh SITE2 No
    ./4-3-sitecmd.sh SITE2 start
    ```

### Observing the Partitioned State

7. Attempt to restore CRR by reconnecting SITE1 as a Recovery site:

    ``` bash
    ./5-2-siteset.sh SITE1 Recovery
    ./6-1-crrswitch.sh SITE2 Yes
    ./4-3-sitecmd.sh SITE2 stop
    ./4-3-sitecmd.sh SITE1 start
    ./4-1-checkhacrr.sh
    ```

    Observe the output carefully:
    - `GRSTATUS` should be `Partitioned` — this confirms that MQ has detected the log divergence.
    - Note the LSN values on both sides. The gap between the `RECOVLSN` you saved and the current tail of SITE1's log identifies the transactions that were committed on SITE1 but never reached SITE2.

8. Stop all Queue Managers before proceeding:

    ``` bash
    ./4-3-sitecmd.sh SITE1 stop
    ./4-3-sitecmd.sh SITE2 stop
    ```

### Examining the Diverged Transactions

9. Use `dmpmqlog` to inspect the SITE1 log entries that occurred after the saved `RECOVLSN`. Filtering by `ObjectName=QUEUE1` narrows the output to only the queue activity that matters:

    ``` bash
    source hacrrenv.sh
    ssh $host11 "dmpmqlog -m MYQMGR -s <RECOVLSN> -r ObjectName=QUEUE1"
    ```

    The output shows the 2 messages that were put to `QUEUE1` on SITE1 after SITE2 went down. These messages exist on SITE1 but not on SITE2. In a real disaster recovery scenario, you would use this information to decide whether to replay these transactions on the surviving site before discarding the isolated log.

10. Analyse the output and note which messages are listed.

### Resolving the Split Brain

11. Cold-start SITE1 to discard its diverged log and allow it to rejoin SITE2:

    ``` bash
    ./6-0-coldsite.sh SITE1
    ./4-3-sitecmd.sh SITE2 start
    ```

12. Verify that replication resumes and `GRSTATUS` returns to `Normal` on both sites.

13. Finally, perform a planned site swap to restore SITE1 as the Live site and SITE2 as the Recovery site, returning to the original configuration.
