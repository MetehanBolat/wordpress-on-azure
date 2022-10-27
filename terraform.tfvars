resourcePrefix = "kuba"
location       = "westeurope"
adminName      = "Metehan"
adminPassword  = "My4w350m3P4s5W0Rd!"
siteConfig = {
  rehber = {
    name            = "kuba-rehber"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    appStackVersion = "7.4"
    managedPipeline = "Classic"
    workerCount     = 1
  }
  hotel = {
    name            = "kuba-hotel"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    appStackVersion = "7.4"
    managedPipeline = "Classic"
    workerCount     = 1
  }
}