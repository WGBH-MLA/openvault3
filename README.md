[![Build Status](https://travis-ci.org/WGBH/openvault3.svg?branch=master)](https://travis-ci.org/WGBH/openvault3)

# openvault3

[Open Vault](http://openvault.wgbh.org), by WGBH Media Library and Archives (MLA),
provides online access to unique and historically important content produced by WGBH.

## Deploy Servers

There are four steps to get the site up from scratch:
- Request servers and everything else from AWS.
- Use Ansible for a basic configuration of the servers.
- Deploy the site with Capistrano.
- Ingest the PBCore.

On an on-going basis there will be:
- Capistrano redeploys to the demo server
- and swaps of the production and demo servers.

For more details, see `scripts/deploy.sh` or review documentation below.

## Deploy, Server Swap and Ingest Requirements
In order to deploy code to the website, swap servers from demo to live and/or ingest PBCore xml you'll need two additional repositories.

- [openvault3_deploy](https://github.com/WGBH/openvault3_deploy)
- [aws-wrapper](https://github.com/WGBH/aws-wrapper)

Make sure you first check out these two repositories and pull the latest code.

For WGBH Open Vault server resources such as ssh keys, urls, AWS site names, please see [Server Resources](https://wiki.wgbh.org/display/MLA/Server+Resources) documentation on the internal wiki.

If you have all the required applications and dependencies, a good first test would be to see if you can obtain the ip addresses for the current live and demo Open Vault servers.

Open your Terminal application.
```
$ cd aws-wrapper
$ bundle exec scripts/ssh_opt.rb
```

This will give you the list of arguments.  For this initial interaction, you are trying to show the ip address of the demo and live servers.
```
$ bundle exec scripts/ssh_opt.rb --name openvault.wgbh-mla.org --ips_by_dns
```

The returned result should be the ip address of the live Open Vault site.

To do the same for the demo site, change the `—-name` argument to `demo.openvault.wgbh-mla.org`
```
$ bundle exec scripts/ssh_opt.rb --name demo.openvault.wgbh-mla.org --ips_by_dns
```

The returned result should be the demo server ip address, different from the previous one.

If those commands completed successfully, you can proceed to deploy Github code to the demo server.

## Deploy Code to Demo Server
Because we don't want to immediately deploy new code changes to the live Open Vault server, we first deploy them to the demo site where you can verify before swapping the server from live to demo so the live site should always be the most up to date version of the code.
```
$ cd openvault3_deploy
```

The next command you'll enter uses the `ssh_opt.rb` script from aws-wrapper to determine and use the demo ip address.  That's why it's important you verify the aws-wrapper is working.
```
$ OV_HOST=`cd ../aws-wrapper && bundle exec scripts/ssh_opt.rb --name demo.openvault.wgbh-mla.org --ips_by_dns` \
OV_SSH_KEY=~/.ssh/openvault.wgbh-mla.org.pem bundle exec cap aws deploy
```

When complete, [go to the demo site](http://demo.openvault.wgbh-mla.org) and verify the code changes that were just deployed are what you desire.

If so, now you'll want to swap the servers so the demo site becomes the public, live site.

## Swap Servers
This will switch which server is the demo and which one is the live.
```
$ cd aws-wrapper
$ bundle exec scripts/swap.rb --name openvault.wgbh-mla.org
```

When that process completes, you can go to the [live Open Vault](http://openvault.wgbh.org) and verify that the new code came deploy that had previously been on the demo site is now live.  You can also visit the demo url if you wish to see if the non-updated code is still in place.

## Ingesting Metadata Records
Open Vault is built around making PBCore xml records accessible.  These are generated from an Open Vault PBCore [Filemaker database](https://wiki.wgbh.org/display/MLA/Creating+and+Updating+Asset+Records).

Exports from that database are presented as single or multiple, zipped xml documents.  If the xml is not valid PBCore, or if it's not structured in a way that will be valid for the Open Vault data modeling, it will fail to ingest those specific records and the errors are recorded in a log file.  If there are multiple xml files trying to be ingested and some are valid, they will continue to be successfully be ingested.

We also run the ingest process on both the demo and live server so they remain record level identical.

Once you have your PBCore xml export run the following commands.
```
$ cd openvault3_deploy
$ for i in `cd ../aws-wrapper && bundle exec scripts/ssh_opt.rb --name openvault.wgbh-mla.org --ips_by_tag` \
; do OV_HOST=$i OV_SSH_KEY=~/.ssh/openvault.wgbh-mla.org.pem \
  bundle exec cap aws ingest OV_PBCORE=/PATH/TO/PBCORE/pbcore_xml.zip & done
```

Make sure to add the `&` after the path to your PBCore to background the reindex on both servers, so they can run in parallel.

Completing that command may take some time because it's ingesting to and restarting Rails.

If you ever have the need to ingest on a single server you can do the following.
Single ingest to live server:
```
$  cd openvault3_deploy
$ OV_HOST=`cd ../aws-wrapper && bundle exec scripts/ssh_opt.rb --name openvault.wgbh-mla.org --ips_by_dns` \
OV_SSH_KEY=~/.ssh/openvault.wgbh-mla.org.pem \
bundle exec cap aws ingest OV_PBCORE=/PATH/TO/PBCORE/pbcore_xml.zip
```
To ingest to demo server, add `demo.`: `--name demo.openvault.wgbh-mla.org`

## Verify Successful Ingest
To verify ingest completed successfully you can view the most recent ingest log files on both the demo and live servers.
View the most recent log file.  At the end of the log there should be a % complete number.  If it's `(100%) succeeded` then the ingest was successful.

Verify log file on live site:
```
$ cd aws-wrapper
$ ssh -i ~/.ssh/openvault.wgbh-mla.org.pem ec2-user@`bundle exec scripts/ssh_opt.rb --name openvault.wgbh-mla.org --ips_by_dns`
$ cd /var/www/openvault/current/log
$ ls -l
$ less ingest.2016-03-28_190938.log
```

Verify log file on demo site:
```
$ cd aws-wrapper
$ ssh -i ~/.ssh/openvault.wgbh-mla.org.pem ec2-user@`bundle exec scripts/ssh_opt.rb --name demo.openvault.wgbh-mla.org --ips_by_dns`
$ cd /var/www/openvault/current/log
$ ls -l
$ less ingest.2016-03-28_190938.log
```

If the ingest was not 100% on either server then you need to review the log file and determine why the failing records are failing, correct the data, then re-import those records.

There may be instances where the ingest is successful on the live site but not the demo.  This could be because code changes that are currently deployed to the live site that would allow xml to be valid have not yet been deployed to the now demo site.  In those cases, follow the Deploy Code to Demo Server instructions and re-ingest the same xml.

Once you've verified the ingest was 100% successful, you should spot check the records themselves on the live and sites.

## Ingest Issues and Restarting Jetty

We had a couple problems with getting Solr restarted and working after we deployed new code to get ingest working.
Also, if the demo instance of the sever (the one you should be deploying to) may be stopped to save AWS costs.  When the server is stopped, Jetty is stopped and you can confirm this by going to the demo site in a browser and trying to search.  Search will not work, so Jetty must be restarted.
You may need to first kill Jetty and then clean and configure before starting then ingesting.
```
$ cd aws-wrapper
$ ssh -i ~/.ssh/openvault.wgbh-mla.org.pem ec2-user@`bundle exec scripts/ssh_opt.rb \
--name demo.openvault.wgbh-mla.org --ips_by_dns`
$ cd /var/www/openvault/current/
```
First, need to stop Jetty if it's running.
```
$ ps aux | grep jetty
```
That should list the running Jetty process.  Find the process number and then enter it after `kill` command.
Example:
```
$ kill 12345
```
You may also need to delete the jettywrapper.log file found within current/jetty

With Jetty now stopped you should clean, config and then start it again.
```
$ bundle exec rake jetty:clean
$ bundle exec rake jetty:config
$ bundle exec rake jetty:start
```
Now you should be ready for ingest.

Once you've verified the ingest was 100% successful, you should spot check the records themselves on the live and demo sites.

## Restarting Jetty After Server Stop / Start

Jetty needs to be restarted on any server that has stop.rb and then start.rb ran on it.  To do this.
```
$ cd aws-wrapper
$ ssh -i ~/.ssh/openvault.wgbh-mla.org.pem ec2-user@`bundle exec scripts/ssh_opt.rb \
--name demo.openvault.wgbh-mla.org --ips_by_dns`
$ cd /var/www/openvault/current/
$ bundle exec rake jetty:start
```

You may also need to use the following command
```
RAILS_ENV=production bundle exec rake jetty:start
```
