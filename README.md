#Head Chef
Manage Chef Environments with Berkshelf, Ridley, and Git

#Installation
Add Head Chef to your repository's Gemfile:

```
gem 'head_chef'
```
Or run in as a standalone

```
gem install head_chef
```

#Usage
Head Chef manages Chef Enviroments using [Berkshelf](https://github.com/berkshelf/berkshelf). Chef Server connections are made via [Ridley](https://github.com/RiotGames/ridley), and are controlled by a [`knife.rb`](http://docs.opscode.com/config_rb_knife.html) file, which should be located in a `.chef` directory. Head Chef will use the closest `.chef/knife.rb` found in its or its parents directories, identical to the Chef CLI tool [`Knife`](http://docs.opscode.com/knife.html). 

**Head Chef must be run in the root of a `git` repository.**

_Note: It is up to the user to manage the Berksfile and Berksfile.lock_
##Environment
The following commands are under `head-chef env` and perform actions on Chef Environments. 

**By default, the Chef Environment used will match the current git branch.** 

For example if the current git branch is `test`, these commands will be run against the Chef Environment named `test`, if it exists.

These commands can be passed the following arguments:

```
-e <environment>,	Applies to the specified Chef Environment 
```

###diff
View cookbook version constraint diff between local Berksfile and Chef Environment.

```
$ head-chef env diff 
```

Sample output:

```
Loading environment test from chef server...
Loading cookbooks from berkshelf...
Calculating diff...
ADD:
  nginx: 2.0.4
  apt: 2.3.0
  bluepill: 2.3.0
  rsyslog: 1.9.0
  build-essential: 1.4.2
  ohai: 1.1.12
  runit: 1.4.0
  yum: 2.4.2
REMOVE:
  java: 1.15.4
  windows: 1.11.0
  chef_handler: 1.1.4
  aws: 1.0.0
```

###list
View Chef Environment cookbooks version contraints

```
$ head-chef env list
```

Sample output:

```
COOKBOOKS:
  aws: 1.0.0
  chef_handler: 1.1.4
  java: 1.15.4
  windows: 1.11.0
```

###sync
`sync` local Berksfile's cookbook version constraints with Chef Environment. 

**The Chef Environment will be created if it does not exist.**

`sync` will also ensure all cookbooks in the environment are present on Chef Server, and that the cookbooks contain the correct content for their version. 

```
$ head-chef env sync
```

A conflict will arise when a cookbook to be uploaded matches a cookbook on Chef Server in version number, but the cookbooks do not have the same content. In general, conflicts will arise when a cookbook has been updated, but the version number was not changed. More often than not, this should be resolved by simply updating the cookbook version number, however, the force option can be used to overwrite the remote cookbook on Chef Server with the local version of the cookbook. This should only be used in exceptional circumstances.

``` 
$ head-chef env sync --force
```

Sample output:

```
Determing side effects of sync with chef environment test...
Uploading cookbooks to chef server...
Using nginx (2.0.4)
Using apt (2.3.0)
Using bluepill (2.3.0)
Using rsyslog (1.9.0)
Using build-essential (1.4.2)
Using ohai (1.1.12)
Using runit (1.4.0)
Using yum (2.4.2)
Uploading nginx (2.0.4) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading apt (2.3.0) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading bluepill (2.3.0) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading rsyslog (1.9.0) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading build-essential (1.4.2) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading ohai (1.1.12) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading runit (1.4.0) to: 'https://api.opscode.com:443/organizations/my-org'
Uploading yum (2.4.2) to: 'https://api.opscode.com:443/organizations/my-org'
Applying Berksfile.lock cookbook version to environment test...
Using nginx (2.0.4)
Using apt (2.3.0)
Using bluepill (2.3.0)
Using rsyslog (1.9.0)
Using build-essential (1.4.2)
Using ohai (1.1.12)
Using runit (1.4.0)
Using yum (2.4.2)
```

Sample conflict: 

```
Determing side effects of sync with chef environment readme-example...
The following cookbooks are in conflict:
test_cookbook: 0.1.0
Use --force to sync environment
```

#Workflow
Head Chef is meant to be run inside a **master cookbook**. A **master cookbook** is simply a git repository which has branches associated with Chef environment. Each branch has a Berksfile representing that environment's cookbook version constraints. 

##Testing/Development
Chef Environments can easily be created with Head Chef to be used for testing/development purposes: 

- Checkout **master cookbook**
- Create a new branch
- Edit Berksfile 
- Update Berksfile.lock
- head-chef env sync

These environments can be versioned by committing the branch back to the **master cookbook**, via pull request.

##Cookbook Promotion
The following outlines a typical cookbook workflow in order to demonstate where Head Chef fits in the process:

- Update Chef cookbook until it is deemed ready for promotion (e.g. new version)
- Checkout `MasterCookbook`
- Checkout/create branch matching Chef Environment
- Edit Berksfile to include updated cookbook
- Update Berksfile.lock to include updated cookbook as well as resolve any new dependencies
- `head-chef env sync`

Similarly, all changes to environments can be versioned by committing back to the **master cookbook** repository. 

##Production
Updates to production occur in a similar fashion, but will most likely have more systems in place. Therefore, let's outline a full Chef Cookbook update workflow in production. 

- Update Chef cookbook until it is deemed ready for promotion (e.g. new version)
- Checkout **master cookbook**
- Checkout/create branch matching Chef Environment
- Edit Berksfile to include updated cookbook
- Update Berksfile.lock to include updated cookbook as well as resolve any new dependencies
- Make pull request to **master cookbook**
- Pull request queues CI server build where required role cookbooks are tested in new/updated environment
- Once environment build passes, pull request is ready for merge
- After merge, environment and cookbooks can be updated via `head-chef env sync`

_Environment changes follow the same path, but exclude the cookbook update_

#Authors
- Mark Corwin (<mcorwin@mdsol.com>)
- Harry Wilkinson (<hwilkinson@mdsol.com>)
- Alex Trull (<atrull@mdsol.com>)

