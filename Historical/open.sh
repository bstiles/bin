#!/bin/bash
cat <<EOF | osascript
property target_URL : "http://www.bstiles.net/"
open location target_URL
EOF
