#!/bin/sh
set -ex

# This script replaces existing iSCSI targets in /etc/iscsi.
# Edit with your target details and credentials.
#
# On restart, /etc/init.d/open-iscsi will automatically
# reconnect to the new targets.

# Clear existing iSCSI target connections
/etc/init.d/open-iscsi stop || true
rm -rf /etc/iscsi
mkdir /etc/iscsi

# Connect to new iSCSI target using the following settings
cat > /etc/iscsi/initiatorname.iscsi <<EOF
InitiatorName=iqn.2018-04.org.example:initiator-host
EOF

cat > /etc/iscsi/iscsid.conf <<EOF
node.session.auth.authmethod = CHAP
node.session.auth.username = iscsiuser_in
node.session.auth.password = password1234
node.session.auth.username_in = iscsiuser_out
node.session.auth.password_in = password5678
node.session.auth.chap_algs = MD5

node.session.timeo.replacement_timeout = 0
node.conn[0].timeo.noop_out_interval = 0
node.conn[0].timeo.noop_out_timeout = 0
node.conn[0].iscsi.HeaderDigest = None
node.conn[0].iscsi.DataDigest = None
EOF

/etc/init.d/open-iscsi start || true

iscsiadm --mode discoverydb --type sendtargets --portal 192.168.200.1 --discover
iscsiadm --mode discoverydb --op show
iscsiadm --mode node --targetname iqn.2018-04.org.example:target-host --portal 192.168.200.1:3260 --login
iscsiadm --mode node --op show
iscsiadm --mode session --print 3

echo "iSCSI Target configured"
