#!/bin/bash

# Logo
echo -e "\033[36;1m ██╗  ██╗  ██████╗ \033[0m" 
echo -e "\033[36;1m ██║  ██║ ██╔═══██╗\033[0m"
echo -e "\033[36;1m ███████║ ██║      \033[0m"
echo -e "\033[36;1m ██╔══██║ ██║   ██║\033[0m"
echo -e "\033[36;1m ██║  ██║ ╚██████╔╝\033[0m"
echo -e "\033[36;1m ╚═╝  ╚═╝  ╚═════╝ \033[0m"
echo -e "\033[36;1m  ██████╗   ██████╗\033[0m"
echo -e "\033[36;1m  ╚═════╝   ╚═════╝\033[0m"
echo -e "\033[33;1m  Homelab as Code by Merox.dev \033[0m"
echo -e "\n"

# Ensure sudo is installed without using sudo
if ! command -v sudo &> /dev/null; then
    echo "sudo is not installed. Installing..."
    apt update && apt install -y sudo
else
    echo "sudo is already installed."
fi

# Function to check and install a package if missing
install_if_missing() {
    local package=$1
    if ! dpkg -l | grep -qw "$package"; then
        echo "Installing $package..."
        sudo apt update && sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
}

# Install essential packages
for package in git curl unzip lsb-release; do
    install_if_missing "$package"
done

# Install Ansible
if ! command -v ansible &> /dev/null; then
    echo "Installing Ansible..."
    export LC_ALL=C.UTF-8
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
else
    echo "Ansible is already installed."
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    echo "Installing Terraform..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y terraform
else
    echo "Terraform is already installed."
fi

# Generate SSH key
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "merox@homelab" -f "$SSH_KEY_PATH" -N ""
    
    echo -e "\e[32mYour public key is:\e[0m"
    cat "${SSH_KEY_PATH}.pub"
    echo -e "\e[33mAdd the public key to GitHub under Deploy Keys and press Enter...\e[0m"
    read -r
else
    echo "SSH key already exists at $SSH_KEY_PATH."
fi

# Test SSH connection to GitHub
echo "Testing SSH connection to GitHub..."
if ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "SSH connection is functional."
else
    echo "SSH connection failed. Check your SSH keys and permissions."
    exit 1
fi

# Clone the repository
REPO_URL="git@github.com:mer0x/homelab.git"
REPO_DIR="/home/homelab"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning repository $REPO_URL into $REPO_DIR..."
    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repository already exists at $REPO_DIR."
fi

# Run Terraform init and apply
TERRAFORM_DIR="$REPO_DIR/terraform/"
if [ -d "$TERRAFORM_DIR" ]; then
    echo "Navigating to $TERRAFORM_DIR..."
    cd "$TERRAFORM_DIR" || exit
    echo "Initializing Terraform..."
    terraform init
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve
else
    echo "Terraform directory $TERRAFORM_DIR does not exist. Check the repository."
    exit 1
fi

echo "Process complete! Terraform has also taken care of Ansible."