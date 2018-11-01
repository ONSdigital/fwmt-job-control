# FWMT Job Control
A Ruby [Sinatra](http://www.sinatrarb.com/) application for manipulating jobs within the Fieldwork Management Tool (FWMT).

## Usage
By default the application provides a form to create a visit job within the FWMT. Change the URL to `/reallocate` to reallocate (an) existing job(s) to a different FWMT user, or `/delete` to delete (an) existing job(s).

## Running
### Docker
Pull the image from Docker Hub using:

  `docker pull sdcplatform/fwmt-job-control`

Start a container using:

  `docker run -d -p 9292:9292 --name=emporium sdcplatform/fwmt-job-control`

&mdash;and access using [http://localhost:9292](http://localhost:9292).

### Natively
Install the RubyGems the application depends on by running:

  `bundle install --without production`

To run this application in development using its [Rackup](http://rack.github.io/) file use:

  `bundle exec rackup config.ru` (the `config.ru` may be omitted as Rack looks for this file by default)

&mdash;and access using [http://localhost:9292](http://localhost:9292). To reload the application using the [Rerun](https://github.com/alexch/rerun) RubyGem every time a file changes use:

  `bundle exec rerun rackup`

## Environment Variables
The environment variables below must be provided:

```
FWMT_DEVELOPMENT_URL
FWMT_PREPRODUCTION_URL
FWMT_PRODUCTION_URL
FWMT_CENSUSTEST_URL
```

## Building
### Docker
To build a new Docker image, first edit the [Dockerfile](https://github.com/ONSdigital/fwmt-job-control/blob/master/Dockerfile) to set values for the `ENV` commands in the file as detailed in the **Environment Variables** section above. Build the Docker image using:

  `docker build -t="sdcplatform/fwmt-job-control" .`

Push the image to Docker Hub using:

  `docker push sdcplatform/fwmt-job-control`

## Copyright
Copyright (C) 2018 Crown Copyright (Office for National Statistics)
