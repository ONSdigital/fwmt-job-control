# FWMT Job Control
A Ruby [Sinatra](http://www.sinatrarb.com/) application for manipulating jobs within the Fieldwork Management Tool (FWMT).

## Running
### Docker
Pull the image from Docker Hub using:

  `docker pull sdcplatform/fwmt-job-control`

Start a container using:

  `docker run -d -p 9292:9292 --name=emporium sdcplatform/fwmt-job-control`

and access using [http://localhost:9292](http://localhost:9292). If using the [Dockerfile](https://github.com/ONSdigital/fwmt-job-control/blob/master/Dockerfile) to build your own image, set values for the `ENV` commands in the file as detailed in the **Environment Variables** section later in this README.

### Natively

Install the RubyGems the application depends on by running:

  `bundle install --without production`

To run this application in development using its [Rackup](http://rack.github.io/) file use:

  `bundle exec rackup config.ru` (the `config.ru` may be omitted as Rack looks for this file by default)

and access using [http://localhost:9292](http://localhost:9292). To reload the application using the [Rerun](https://github.com/alexch/rerun) RubyGem every time a file changes use:

  `bundle exec rerun rackup`

## Environment Variables
The environment variables below must be provided:

```
FWMT_DEVELOPMENT_URL
FWMT_PREPRODUCTION_URL
FWMT_PRODUCTION_URL
```

## Copyright
Copyright (C) 2018 Crown Copyright (Office for National Statistics)