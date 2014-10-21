## Sansad API

This is the code that powers the [Sansad API](http://sansad.co/api).

### Overview

The Sansad API has two parts:

* A light **front end**, written in Ruby using [Sinatra](http://www.sinatrarb.com).
* A **back end** of data scraping and loading tasks, written in Ruby.

The **front end** is essentially read-only. Its job is to translate an API call (the query string) into a single database query (usually to MongoDB), wrap the resulting JSON in a bit of pagination metadata, and return it to the user.

Endpoints and behavior are determined by introspecting on the classes defined in `models/`. These classes are also expected to define database indexes where applicable.

The front end tries to maintain as little model-specific logic as possible. There are a couple of exceptions made (like allowing disabling of pagination for `/legislators`) &mdash; but generally, adding a new endpoint is as simple as adding a model class.

The **back end** is a set of tasks (scripts) whose job is to write data to the collections those models refer to. All data is stored in [MongoDB](http://www.mongodb.org/).

We currently manage these tasks [via cron](https://github.com/KumarL/sansad/blob/master/config/cron/production.crontab). A small task runner wraps each script in order to ensure any "reports" created along the way get emailed to admins, to catch errors, and to parse command line options.

While the front end and back end are mostly decoupled, many of them do use the definitions in `models/` to save data (via [Mongoid](https://github.com/mongoid/mongoid)) and to manage duplicating "basic" fields about objects onto other objects.

The API **never performs joins** -- if data from one collection is expected to appear as a sub-field on another collection, it should be copied there during data loading.

### Setup - Dependencies

If you don't have [Bundler](http://rubygems.org/gems/bundler), install it:

```bash
gem install bundler
```

Then use Bundler to install the Ruby dependencies:

```bash
bundle install --local
```

The task to extract text from PDF documents of bills is performed through the [docsplit gem](http://documentcloud.github.com/docsplit/). If you use a task that does this, you will need to install a system dependency, `pdftotext`.

On Linux:

```bash
sudo apt-get install poppler-data
```

Or on OS X:

```bash
brew install poppler
```

### Setup - Configuration

Copy the example config files:

```bash
cp config/config.yml.example config/config.yml
cp config/mongoid.yml.example config/mongoid.yml
cp config.ru.example config.ru`
```

You **don't need to edit these** to get started in development, the defaults should work fine.

In production, you may wish to turn on the API key requirement, and add SMTP server details so that mail can be sent to admins and task owners.


### Running tasks

The API uses `rake` to run data loading tasks, and various other API maintenance tasks.

Every directory in `tasks/` generates an automatic `rake` task, like:

```bash
rake task:legislators
```

### License

This project is [licensed](LICENSE) under the [GPL v3](http://www.gnu.org/licenses/gpl-3.0.txt).
