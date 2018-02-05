[![Puppet Forge](https://img.shields.io/puppetforge/v/vStone/percona.svg)](https://github.com/tspeigner/puppet-code_deploy)

# Puppet Code Deploy

This module adds a Task for running puppet code deploy <environment>.

For Puppet Enterprise users, this means you can allow users or admins to do a Puppet code deployment without giving them SSH access to your Puppet master! The ability to run this task remotely or via the Console is gated and tracked by the [RBAC system](https://puppet.com/docs/pe/2017.3/rbac/managing_access.html) built in to PE.

## Requirements

This module is compatible with Puppet Enterprise and Puppet Bolt.

* To [run tasks with Puppet Enterprise](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html), PE 2017.3 or later must be used.

* To [run tasks with Puppet Bolt](https://puppet.com/docs/bolt/0.x/running_tasks_and_plans_with_bolt.html), Bolt 0.5 or later must be installed on the machine from which you are running task commands. The master receiving the task must have SSH enabled.

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

### Bolt

With [Bolt](https://puppet.com/docs/bolt/0.x/running_tasks_and_plans_with_bolt.html), you can run this task on the command line like so:

```shell
bolt task run code_deploy environments=production -n master.corp.net
```

## Parameters

* `environments`: A comma-separated list of Puppet environments. Note: The --all feature is not allowed.


## Finishing the Job

If you are on Puppet Enterprise 2017.3 or higher and you only have one Puppet master, you're done. There's nothing else you need to do after running this task.