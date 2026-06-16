# Unplanned switch - disaster recovery


## Disaster

Shutdown the QueueManagers on the SITE1

Start a Live environment on SITE2 - ahh QM cannot start

Start a Live environment on SITE2 without SITE1

Message can now flow

## Recovery 

Make SITE1 a recovery site 

Start SITE1 and check status

Reovery complete eventually

## Split brain

Shutdown the QueueManagers on the SITE2

Start a Live environment on SITE1 without SITE2

Send a couple of messages

Stop SITE1

Now Start QM on SITE2 - can you make it active?

Send a couple of messages

Start both sides 

Collect the INTILSN and RECOVLSN

Get dmpmqlog

Cold start SITE2

Fix all to have SITE1 Live and SITE2 Recovery



