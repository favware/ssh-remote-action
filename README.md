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
