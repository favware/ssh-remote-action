#!/usr/bin/env bash

# Check if SSH_USERNAME is set
if [ -z "${SSH_USERNAME}" ]; then
    echo "with.username is not set. Exiting..."
    exit 1;
fi

# Check if SSH_HOST is set
if [ -z "${SSH_HOST}" ]; then
    echo "with.host is not set. Exiting..."
    exit 1;
fi

# Check if SSH_COMMAND is set
if [ -z "${SSH_COMMAND}" ]; then
    echo "with.command is not set. Exiting..."
    exit 1;
fi

# Default to SSH port 22
SSH_PORT=${SSH_PORT:-22}

# Define the default SSH arguments that apply for both key and password flows
SSH_ARGS="-o StrictHostKeyChecking=no -p ${SSH_PORT} ${SSH_USERNAME}@${SSH_HOST}"

eval "$(ssh-agent -s)"

if [ -n "${SSH_KEY}" ]; then
    echo "Using SSH key..."

    # Write the private key to a file
    echo "${SSH_KEY}" > ./private.key

    # Set the permissions
    chmod 600 ./private.key

    # Check if the SSH_KEY_PASSPHRASE is empty
    if [ -z "${SSH_KEY_PASSPHRASE}" ]; then
        echo "SSH Key Passphrase is empty, just adding the key to the SSH agent..."
        # Add the private key to the SSH agent
        ssh-add ./private.key > /dev/null
        echo "SSH Identity Added"
    else
        echo "SSH Key Passphrase is set, creating a script to echo the passphrase and adding the key to the SSH agent..."
        # Create a script that will echo the passphrase
        printf "%s\n" "#!/usr/bin/env bash" "echo ${SSH_KEY_PASSPHRASE}" > ./ssh-passphrase
        chmod +x ./ssh-passphrase

        # Set the permissions
        DISPLAY=1 SSH_ASKPASS="./ssh-passphrase" ssh-add ./private.key > /dev/null
        echo "SSH Identity Added"
    fi

    if [ "${SILENT}" == "true" ]; then
        echo "Executing the SSH command silently..."
        ssh ${SSH_ARGS} "${SSH_COMMAND}" > /dev/null
    else
        echo "Executing the SSH command..."
        ssh ${SSH_ARGS} "${SSH_COMMAND}"
    fi

elif [ -n "${SSH_PASSWORD}" ]; then

    echo "Using an SSH password. It is recommended you instead setup a public/private key pair and use SSH keys instead"

    # Execute the SSH command
    if [ "${SILENT}" == "true" ]; then
        echo "Executing the SSH command silently..."
        sshpass -p "${SSH_PASSWORD}" ssh ${SSH_ARGS} "${SSH_COMMAND}" > /dev/null
    else
        echo "Executing the SSH command..."
        sshpass -p "${SSH_PASSWORD}" ssh ${SSH_ARGS} "${SSH_COMMAND}"
    fi

else
    echo "Neither inputs.key nor inputs.password are set. Exiting..."
    exit 1;
fi

