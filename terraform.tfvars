resourcePrefix = "kuba"
location       = "westeurope"
siteConfig = {
  rehber = {
    name            = "kuba-rehber"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    managedPipeline = "Classic"
    workerCount     = 1
  }
  hotel = {
    name            = "kuba-hotel"
    repo            = "https://github.com/azureappserviceoss/wordpress-azure" ## if null, no deployments
    branch          = "master" ## makes sense only if repo is not null
    appStack        = "php"
    managedPipeline = "Classic"
    workerCount     = 1
  }
}