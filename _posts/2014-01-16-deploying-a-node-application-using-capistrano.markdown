---
layout: post
title:  "Deploying a node application using capistrano"
date:   2014-01-16 20:37:00
categories: node.js development
---


This is a guide to deploy a node application using the well known [Capistrano][Capistrano] gem with a bit of help of the [capistrano-node-deploy][capistrano-node-deploy] gem.

This guide uses ruby to deploy your node.js application. So I assume that you habe both [ruby][ruby] and [bundler][bundler] (a package manager similar to [npm][npm]) installed. I also provide some feedback at the end, why I used ruby and not JavaScript for deployment.

<!--more-->

## Deploying the app

### Preparation

As all ruby projects, we have to add this to the `Gemfile`:

{% highlight ruby %}
gem 'capistrano', '~> 2' # node-deploy has no capistrano3 support yet
gem 'capistrano-node-deploy'
{% endhighlight %}

If you don’t have a `Gemfile` yet, you should create one, and probably want to prepend it with this line – so bundler does know where to look for the gems:

{% highlight ruby %}
source 'https://rubygems.org'
{% endhighlight %}

Then we can install the gems using `bundler`:

{% highlight bash %}
# installing the gems using bundler
bundle
{% endhighlight %}

Beware of the Capistrano version. At the time of writing, the capistrano-node-deploy gem does not work with the new Capistrano 3 version, so we have to stick to Capistrano 2 for the time being.

Now add a file called `Capfile`. Use this as blueprint but change all stuff that is needed:

{% highlight ruby %}
require 'capistrano/node-deploy'

set :application, 'example_app'
set :user, 'deploy'

set :repository,  'git@github.com/your_name/example_app.git'
set :scm, :git

# If you do not have a web accessible repo yet, uncomment the following:
# set :deploy_via, :copy

set :deploy_to, '/var/www/example_app'
set :node_user, 'mr_node' # user that runs the app

role :app, 'example.app.com'
{% endhighlight %}

### Deploy it

Now you should be able to deploy the app using:

{% highlight bash %}
bundle exec cap deploy
{% endhighlight %}

Do this every time you have committed (and pushed) some changes that you want to deploy.

## Starting the app

Capistrano-node-deploy comes with [upstart][upstart]  support out of the box. If you are using upstart, then you might want to set the following `upstart_job_name` setting, if the name of your upstart job is not `APP_NAME-ENV_NAME`. (Add this to your `Capfile`:)

{% highlight ruby %}
set :upstart_job_name, 'example_app'
{% endhighlight %}

Beware that it will rewrite the upstart script on every deploy if it has changed. So if you might want to change some things, set the appropriate variables in your `Capfile` and don’t change the script on the remote server manually. Which variables are there? Well, best to look in the [code][code] for them.

If you are using init.d at the moment, like me, then I will give you one tipp: Just switch to upstart. It’s just easier. At least for me, with init.d it really fucked up the permissions when starting with sudo, and without it simply fails ending up in multiple node instances running. And another plus for upstart: The upstart script is way simpler.

Now `bundle exec cap deploy` will also restart the app properly. Try it:

{% highlight bash %}
bundle exec cap deploy
{% endhighlight %}

Capistrano also allows to do stuff on the server, not only deploys. So you could start/stop/restart your node app easily directly (without a deploy). Just try:

{% highlight bash %}
bundle exec cap node:restart
{% endhighlight %}

### Some helpful options

If your node is not running on `/usr/bin/node` you might want to set the `node_binary` option to where your node is installed:

{% highlight ruby %}
set :node_binary, '/usr/local/bin/node'
{% endhighlight %}

If you want pass some command line arguments to your app, you should specify them directly in your `main` part in your `package.json`. Capistrano-node-deploy does not have another way implemented to just pass them in directly. So something like:

{% highlight json %}
{
  "main": "my_app.js —port=8124"
}
{% endhighlight %}

Although I suggest to make those things configurable through a config file depending on the environment the app is running, to gain some flexibility.

And the last tipp I want to give is, setting the environment for your app. It is set to `production` by default, but if you have a staging server you might want to set in the `Capfile`:

{% highlight ruby %}
set :node_env, 'staging'
{% endhighlight %}

## Recap

This is pretty simple and Capistrano is a tool that is pretty battle tested, because it is used literally everywhere in the Ruby on Rails world. But although it works, there are some reasons why I am not totally fond of this solution:

The first obvious reason is that using Capistrano is in need of ruby. It is not a problem for me, I always have ruby installed for some other projects, but having a JavaScript app relying on ruby although it’s only for deployment feels weird. The second and bigger point is it does not take good use of the npm hooks defined in the `package.json`.

If you are using [nodejitsu][nodejitsu] as server you know what I mean with the latter point. I really like the way the `jitsu` command works when deploying. Especially the handling of the version number is way better then the Capistrano solution. But if you do not use nodejitsu, there is no other similar solution like it in the node realm – at least I could not find it. I thought about starting to write one, but the capistrano solution is easier for now, and if you want to deploy right away, that’s a way to go.

I hope this little go through is useful to anyone.

*P.S.: Someone cares for writing a node deploy mechanism similar to `jitsu` without the nodejitsu dependency? Fame and glory awaits.*

[Capistrano]: http://capistranorb.com
[capistrano-node-deploy]: https://github.com/loopj/capistrano-node-deploy
[ruby]: https://www.ruby-lang.org
[bundler]: http://bundler.io
[npm]: https://npmjs.org
[upstart]: http://upstart.ubuntu.com
[code]: https://github.com/loopj/capistrano-node-deploy/blob/master/lib/capistrano/node-deploy.rb#L50
[nodejitsu]: http://nodejitsu.com
