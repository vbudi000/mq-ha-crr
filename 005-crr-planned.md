# Planned switch with CRR

This unit demonstrates a planned switchover

To demonstrate this - you need 4 terminal sessions:

- One running `ssh host11 watch -n 5 dspmq -o nativeha -g -x -m qmgr`
- One running `ssh host21 watch -n 5 dspmq -o nativeha -g -x -m qmgr`
- One running mq_message_sender.sh
- One more terminal running the failover script and notice how the fail over behaves
 
 1. Check where is the Live group - assumes that the current live group is SITE1; then run the command [scripts/5-1-siteswap.sh](scripts/5-1-siteswap.sh). 

 2. While the command runs, see how the status in the `dspmq` windows changes:
 
    - SITE1 would change from Live > Unknown > Pending Recovery > Recovery 
    - SITE2 would change from Recovery > Unknown > Pending Live > Life

3. How long does the sending program failed? Typically this would take around 7-15 seconds. 

4. Run the 5-1-siteswap.sh again a couple of times to observe the behavior of the MQ Queue Manager and how long it takes for the failover to become active again.