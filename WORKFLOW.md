The berkshelf workflow to run with head_chef:

repo/gitref                       | org         | aws acct | environment
master_cookbook “distro”          | mdsol-green | green    | distro
master_cookbook “sandbox”         | mdsol-green | green    | sandbox
master_cookbook “performance”     | mdsol-green | green    | performance
master_cookbook “validation”      | mdsol-green | green    | validation
master_cookbook “innovate” +tag   | mdsol-red   | red      | innovate
master_cookbook “production” +tag | mdsol-red   | red      | production

In each master_cookbook branch there will be a Berksfile (referencing the internal cookbooks via git), Berksfile.lock (locking both the git and community versions) + metadata.rb referencing all the ‘first level’ community cookbooks we use.

Berksfile format is like a Gemfile - we reference each internal/git-sourced cookbook as a git repo of its own, maybe with a branch or ref:

```
cookbook "mdsol_newrelic", :git => "git@github.com:mdsol/mdsol_newrelic_cookbook.git"
```

Berksfile.lock format is like a Gemfile.lock:

The Berksfile.lock format is like a Gemfile.lock - with locked versions for community cookbooks and locked git refs for internal/git-sourced cookbooks..

```JSON
{
  "sources": {
    “local-cookbook”: {
      "path": "."
    },
    "sudo": {
      "locked_version": "2.1.2"
    },
    "runit": {
      "locked_version": "1.3.0"
    }
}
```

Both types of ref, the version and the git ref are derived from the metadata dependency map generated through downloading and checking each.

berks on its own creates/manages the Berksfile.lock based on the latest versions of any cookbook dependencies found in the metadata.rb and refs in the Berksfile.

berks update checks for newer community cookbooks and git refs from the dependency tree and puts them in the Berksfile.lock.

berks upload uploads set versions / verifies those versions exist in the org.

berks apply creates an environment based on the versions in the Berksfile.lock.

Github PRs will be used to merge the changes down the branches.

We will use this ‘master cookbook’ and headchef to push our changes to the org for each branch, maybe even as there result of a test convergence or other tests. It should be easy to drive with testkitchen jenkins results as the input/deciding factor.

