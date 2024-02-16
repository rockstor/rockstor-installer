repo_file=$1
# The following keys are currently identical:
# - https://pkgs.tailscale.com/stable/opensuse/leap/15.4/repo.gpg
# - https://pkgs.tailscale.com/stable/opensuse/leap/15.5/repo.gpg
# - https://pkgs.tailscale.com/stable/opensuse/tumbleweed/repo.gpg
# Better to use repo specific key when sutable encironmental variable of parameter found.
echo 'gpgkey=https://pkgs.tailscale.com/stable/opensuse/leap/15.5/repo.gpg' >> ${repo_file}