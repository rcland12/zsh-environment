sudo cp /usr/share/openssh/sshd_config /etc/ssh/sshd_config
sudo tee /etc/ssh/sshd_config.d/00-local.conf >/dev/null <<'EOF'
Banner /etc/ssh/banner
LogLevel VERBOSE
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 5
PermitRootLogin no
AuthenticationMethods publickey
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no
AllowUsers russ
X11Forwarding no
AllowTcpForwarding local
PermitTunnel no
ClientAliveInterval 300
ClientAliveCountMax 2
EOF
sudo sshd -t && sudo systemctl reload ssh
