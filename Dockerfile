FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND noninteractive

# Run updates
RUN apt update; apt -y dist-upgrade

# Install the basics
RUN apt -y install sudo curl man tmux vim net-tools htop nano

# Install tools from Kali
RUN apt -y install kali-linux-core

# Install SSH server
RUN apt -y install ssh
# Allow password authentication for initial configuration
RUN sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Add SSH public key to authorized_keys
RUN mkdir -p /root/.ssh/authorized_keys && chmod 700 /root/.ssh
COPY id_ed25519.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

    
# Disable password login and root login after adding the key
RUN sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Start the SSH service
RUN service ssh start

# Expose SSH port
EXPOSE 22

# Clean up
RUN apt -y autoremove

WORKDIR /root

CMD ["/usr/sbin/sshd", "-D"]
