Head Chef
========

The head-chef gem can be used to create environments based on the
branches in a git repository containing a master cookbook that uses
Berkshelf for dependency management.

Different Chef environments (eg. production and non-production) may 
be located in different Chef organizations; this is configurable.

#Usage

To create or update the environment for the current branch:

```bash
head-chef env sync
```

The sync command accepts these options: 

```bash
--force, Overwrites cookbooks on chef server 
``` 

To compare the differences between the current branch and the 
environment in use on the Chef server:

```bash
head-chef env diff
```

The above commands accept a number of options:

```bash
-e <environment>,      Applies to the specified Chef environment 
```


