# Call Jenkins build from Ruby

This small container environment gives you a Jenkins instance you can configure, and allows you to run builds by calling Ruby methods. It's backed by the [jenkins_api_client](https://github.com/arangamani/jenkins_api_client) gem by [@arangamani](https://github.com/arangamani). Please visit their repo for more information on how to apply the gem.

## Setup

Bring up the environment with `docker-compose up -d`. Open `http://localhost:11037` in your browser. After Jenkins takes its time to set up, you'll be asked to log in. Use the username `admin` and supply a password stored on the Jenkins container. Quickly retrieve this with `docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword | pbcopy`. (Use `xclip -sel clip` over `pbcopy` on Linux.) The password will be on your clipboard, ready to paste in.

Once Jenkins is ready, there should be a pipeline named `hello-world`.

The pipeline script is defined with the following code:

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

## Testing

You should be able to run the following to run the tests:

```
docker-compose build; docker-compose run --rm ruby rspec jenkins_api_caller_spec.rb
```

Your `hello-world` pipeline should now have a successful build.
