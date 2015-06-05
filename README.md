# Dataloop


This role installs and configures the dataloop.io agent to send
metrics back to dataloop.io.

## Usage

In order to automatically add a node to dataloop, create a file in
your ansible repo named group_vars/dataloop using ansible-vault.

Make sure the file has the following content:

```
---
dataloop_api_key: <insert_dataloop_api_key_here>
```

And optionally the startup tags below:

```
---
dataloop_tags: <insert_csv_list_of_tags_here>
```

Now ensure that your nodes are members of the "dataloop" group in your
inv/hosts file and run ansible. The dataloop client should be
installed automatically and your nodes should start showing up in the
dataloop web interface.
