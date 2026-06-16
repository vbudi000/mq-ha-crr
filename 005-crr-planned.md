# Planned switch with CRR

This unit demonstrates a planned switchover

To demonstrate this - you need 4 terminal windows:

- One running `ssh host11 watch -n 5 dspmq -o nativeha -g -x -m qmgr`
- One running `ssh host21 watch -n 5 dspmq -o nativeha -g -x -m qmgr`
- One running mq_message_sender.sh
- One more terminal running the failover script and notice how the fail over behaves
 