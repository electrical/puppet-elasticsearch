If you have a bugfix or new feature that you would like to contribute to this puppet module, please find or open an issue about it first. Talk about what you would like to do. It may be that somebody is already working on it, or that there are particular issues that you should know about before implementing the change.

1. Run the rspec tests and ensure it completes without errors with your changes.

2. Run the acceptance tests

These instructions are for Ubuntu 14.04

* install docker 
 * sudo usermod -a -G docker $USER
* export RS_SET='ubuntu-server-1404-x64' # see spec/acceptance/nodesets for more
* export VM_PUPPET_VERSION='3.8.0'
* wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb
* wget https://forgeapi.puppetlabs.com/v3/files/puppetlabs-stdlib-3.2.0.tar.gz
* wget https://forgeapi.puppetlabs.com/v3/files/puppetlabs-apt-1.4.2.tar.gz
* export files_dir=$(pwd)
* bundle install
* bundle exec rspec --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter spec/acceptance/*_spec.rb

```
    Hypervisor for ubuntu-14-04 is docker
    Beaker::Hypervisor, found some docker boxes to create
    Provisioning docker
    provisioning ubuntu-14-04
    ...
    Finished in 18 minutes 6 seconds
    224 examples, 0 failures, 3 pending
```

3. Rebase your changes
Update your local repository with the most recent code from the main this puppet module repository, and rebase your branch on top of the latest master branch. We prefer your changes to be squashed into a single commit.

4. Submit a pull request
Push your local changes to your forked copy of the repository and submit a pull request. In the pull request, describe what your changes do and mention the number of the issue where discussion has taken place, eg “Closes #123″.
