[![Puppet Forge](https://img.shields.io/puppetforge/v/tspy/code_deploy.svg)](https://forge.puppet.com/tspy/code_deploy)

# Puppet Code Deploy

This module adds a Task for running puppet code deploy <environment>.

## Requirements

This module is compatible with Puppet Enterprise.

* To [run tasks with Puppet Enterprise](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html), PE 2017.3 or later must be used.

## Usage

### Puppet Enterprise Tasks

With Puppet Enterprise 2017.3 or higher, you can run this task [from the console](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks_in_the_console.html) or the command line.

Here's a command line example where we deploy the `production` code enviroment on the Puppetmaster, `master.corp.net`:

```shell
[tommy@workstation]$ puppet task run code_deploy environments=production -n master.corp.net

Starting job ...
New job ID: 66
Nodes: 1

Started on master.inf.puppet.vm ...
Finished on node master.inf.puppet.vm
  production :
    result : Successfully deployed the production environment

Job completed. 1/1 nodes succeeded.
Duration: 15 sec
```

Here's a command line example where we deploy the `production` and `dev` code enviroment on the Puppetmaster, `master.corp.net`:

```shell
puppet task run code_deploy environments=production,dev -n master.inf.puppet.vm
Starting job ...
New job ID: 69
Nodes: 1

Started on master.inf.puppet.vm ...
Finished on node master.inf.puppet.vm
  dev :
    result : Successfully deployed the dev environment

  production :
    result : Successfully deployed the production environment

Job completed. 1/1 nodes succeeded.
Duration: 30 sec
```

## Parameters

* `environments`: A comma-separated list of Puppet environments. Note: The --all feature is not allowed.