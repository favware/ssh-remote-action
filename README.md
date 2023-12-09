# SSH Remote Action

SSH Remote Action (ssh-remote-action) is a GitHub action for executing a SSH
command on a remote server. An example use case of this action is deploying your
application on your remote server after publishing a new release through another
GitHub workflow job.

## Usage

`.github/workflows/continuous-deployment.yml`

```yml
on:
  release:
    types: [published]

jobs:
  publish:
    name: Publish application
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Project
        uses: actions/checkout@v4
      # Do whatever you need to do to publish your application

  deploy:
    name: Deploy on remote server
    runs-on: ubuntu-latest
    needs: publish
    steps:
      - name: Deploy on remote server
        uses: favware/ssh-remote-action@v1
        with:
          host: ${{ secrets.SSH_HOST }}
          port: ${{ secrets.SSH_PORT }}
          key: ${{ secrets.SSH_KEY }}
          passphrase: ${{ secrets.SSH_KEY_PASSPHRASE }}
          username: ${{ secrets.SSH_USERNAME }}
          command: ${{ secrets.SSH_COMMAND }}
```

### Ensuring that the output from the command is not printed to the logs

You may not want the output of the SSH logs to be printed to the GitHub action
logs. To achieve this you can provide the `silent` input with value of `true`.
This will take your `command` and transform it to:

```sh
sh -c '${{ inputs.command }}' > /dev/null 2>&1
```

Alternatively you can also provide this directly to your SSH command, in that
case make sure you do NOT set `silent` to true. For example if we want to call a
script called `deploy.sh` the syntax is:

```sh
sh -c '/path/to/deploy.sh' > /dev/null 2>&1
```
