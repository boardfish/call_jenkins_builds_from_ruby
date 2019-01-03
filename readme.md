# Call Jenkins build from Ruby

This small container environment gives you a Jenkins instance you can configure, and allows you to run builds by calling Ruby methods.

## Setup

Bring up the environment with `docker-compose up -d`. After Jenkins takes its time to set up, you'll be asked to supply a password stored on the Jenkins container. Quickly retrieve this with `dc exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword | pbcopy`. (Use `xclip -sel clip` over `pbcopy` on Linux.) The password will be on your clipboard, ready to paste in.

Create the default user `user` with password `password`.

Install the plugins as recommended – this'll let you make a pipeline, which is what we'll be calling with Ruby.

Once Jenkins is ready, create a pipeline named `hello-world`. Check 'This project is parameterised' and give a parameter `foo` with a default value of your choice.

Define the pipeline script with the following code:

```groovy
pipeline { 
    agent any 
    stages {
        stage('Build') { 
            steps { 
                println 'hello world'
                println foo
            }
        }
    }
}
```

Save the pipeline.

## Testing

You should now be able to run the following to run the tests:

```
docker-compose build; docker-compose run --rm ruby rspec jenkins_api_caller_spec.rb
```

Your `hello-world` pipeline should now have a running job. Inspect the output to make sure the `foo` parameter was sent through from the tests.

## Usage

```
require_relative 'jenkins_api_caller'
credentials = {
    username: 'user',
    password: password,
    host: 'http://jenkins:8080'
  }
JenkinsApiCaller.run_job(job_name: 'hello-world', credentials: credentials, params: { foo: 'test' })
JenkinsApiCaller.build_status(job_name: 'hello-world', credentials: credentials) 
```
