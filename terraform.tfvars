resourcePrefix = "cuba"
location       = "westeurope"
adminContact   = "metehan@metehanbolat.com"
adminName      = "Metehan"
adminPassword  = "My4w350m3P4s5W0Rd!"
siteConfig = {
  rehber = {
    name            = "cuba-rehber"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    appStackVersion = "7.4"
    managedPipeline = "Classic"
    workerCount     = 1
    dnsName         = "kubalirehber.com"
    email           = "info@kubalirehber.com"
  }
  hotel = {
    name            = "cuba-hotel"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    appStackVersion = "7.4"
    managedPipeline = "Classic"
    workerCount     = 1
    dnsName         = "talihavana.com"
    email           = "info@talihavana.com"
  }
}