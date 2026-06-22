# Unplanned switch - disaster recovery


## Disaster

Now first lets simulate a disaster:

1. Stop all message input - the `mq_message_sender.sh` program

2. Clean up the queue QUEUE1 by running `mq_message_receiver.sh`. 

3. Check that QDEPTH of the QUEUE1 is 0 and then proceed.

4. Run `mq_message_sender.sh 5` - which will send 5 messages to the QUEUE1 and it will be replicated. 

``` bash
cd mq-ha-crr/scripts
sudo su - mqm /tmp/mq_message_sender.sh 5
```

5. Shutdown all QueueManagers by running the command:

``` bash
cd mq-ha-crr/scripts
./4-3-sitecmd.sh SITE1 stop
./4-3-sitecmd.sh SITE2 stop
```

7. Start a Live environment on SITE2 and check its status 

``` bash
source ./hacrrenv.sh
./5-2-siteset.sh SITE2 Live
./4-3-sitecmd.sh SITE2 start
./rundspmq.sh ${host21}
```

8. Note that the status is Pending recovery - waiting for connection. This is caused by the Recovery site is enabled and it is waiting for reconnection. 

``` bash
./4-3-sitecmd.sh SITE2 stop
./6-1-crrswitch.sh SITE2 No
./4-3-sitecmd.sh SITE2 start
./rundspmq.sh ${host21}
```

9. If the status becomes active - start the message sender for 5 messages. Then check the receiver - make sure that all the send messages from step 4 and this step are retrieved (10 messages)

## Recovery 

To get back to a full CRR environment, perform the following:

1. Make SITE1 a recovery site 

``` bash
cd mq-ha-crr/scripts
./5-2-siteset.sh SITE1 Recovery
./4-3-sitecmd.sh SITE1 start
```

2. Check status

``` bash
cd mq-ha-crr/scripts
./4-1-checkhacrr.sh
```

    - Watch the status of SITE2 to become `Live`
    - Watch the SITE1 status of INSYNC and BACKLOG - eventually `INSYNC` becomes `Yes` and `BACKLOG` becomes `0`

## Split brain

Now that is a normal DR without any split brain scenario

1. Stop all message input - the `mq_message_sender.sh` program; and swap the site back to SITE1.

``` bash
./5-1-siteswap.sh
```

2. Clean up the queue QUEUE1 by running `mq_message_receiver.sh`. 

3. Check that QDEPTH of the QUEUE1 is 0 and then proceed.

4. Run `mq_message_sender.sh 5` - which will send 5 messages to the QUEUE1 and it will be replicated. 

``` bash
cd mq-ha-crr/scripts
sudo su - mqm /tmp/mq_message_sender.sh 5
```

5. Shutdown all QueueManagers by running the command:

``` bash
cd mq-ha-crr/scripts
./4-3-sitecmd.sh SITE1 stop
./4-3-sitecmd.sh SITE2 stop
```

6. Simulate a split brain situation by feeding messages to only SITE1, set the CRR `Enabled` to `No`: 

``` bash
cd mq-ha-crr/scripts
./6-1-crrswitch.sh SITE1 No
./4-3-sitecmd.sh SITE1 start
su - mqm /tmp/mq_message_sender.sh 2
./4-3-sitecmd.sh SITE1 stop
./6-1-crrswitch.sh SITE1 Yes
```

7. Start a Live environment on SITE2 without CRR enabled and check its status 

``` bash
source ./hacrrenv.sh
./5-2-siteset.sh SITE2 Live
./6-1-crrswitch.sh SITE2 No
./4-3-sitecmd.sh SITE2 start
```

9. If the status becomes active - start the message sender for 5 messages. Then check the receiver - make sure that all the send messages from step 4 and this step are retrieved (10 messages)

10. Try to recover from disaster

``` bash
cd mq-ha-crr/scripts
./5-2-siteset.sh SITE1 Recovery
./4-3-sitecmd.sh SITE1 start
./4-1-checkhacrr.sh
```

    - What are the status of the configuration
    - Do you see `GRSTATUS` of `Partitioned` 
    - Save the checkhacrr output - especially the collected LSN numbers

11. Stop all Queue Managers

``` bash
./4-3-sitecmd.sh SITE1 stop
./4-3-sitecmd.sh SITE2 stop
```

12. Get dmpmqlog for SITE1 and SITE2

13. Analyze the output

14. Cold start SITE1

``` bash
./6-0-coldsite.sh SITE1
```

Fix all to have SITE1 Live and SITE2 Recovery



