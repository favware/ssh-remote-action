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
SSH_ARGS="-p ${SSH_PORT} ${SSH_USERNAME}@${SSH_HOST} \"${SSH_COMMAND}\""

eval "$(ssh-agent -s)"

if [ -n "${SSH_KEY}" ]; then

    # Write the private key to a file
    echo "${SSH_KEY}" > ./private.key

    # Set the permissions
    chmod 600 ./private.key

    # Check if the SSH_KEY_PASSPHRASE is empty
    if [ -z "${SSH_KEY_PASSPHRASE}" ]; then
        # Add the private key to the SSH agent
        ssh-add ./private.key < /dev/null
    else
        # Create a script that will echo the passphrase
        printf "%s\n" "#!/usr/bin/env bash" "echo ${SSH_KEY_PASSPHRASE}" > ./ssh-passphrase
        chmod +x ./ssh-passphrase

        # Set the permissions
        DISPLAY=1 SSH_ASKPASS="./ssh-passphrase" ssh-add ./private.key < /dev/null
    fi

    # Execute the SSH command
    ssh ${SSH_ARGS}

elif [ -n "${SSH_PASSWORD}" ]; then

    # Execute the SSH command
    sshpass -p "${SSH_PASSWORD}" ssh ${SSH_ARGS}

else
    echo "Neither inputs.key nor inputs.password are set. Exiting..."
    exit 1;
fi
