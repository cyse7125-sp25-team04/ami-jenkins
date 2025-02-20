import jenkins.model.*

import hudson.security.*

import jenkins.install.*

import java.util.Properties

import hudson.model.RestartListener


// Get the Jenkins instance

def instance = Jenkins.get()


// Load environment variables from the properties file

def props = new Properties()

def envFile = new File('/etc/jenkins.env')

if (envFile.exists()) {

    props.load(envFile.newDataInputStream())

} else {

    throw new RuntimeException("/etc/jenkins.env file not found")

}


def adminId = props.getProperty('ADMIN_ID')

def adminPassword = props.getProperty('ADMIN_PASSWORD')


// Check if the environment variables are set

if (adminId == null || adminPassword == null) {

    throw new RuntimeException("Environment variables ADMIN_ID and/or ADMIN_PWD are not set")

}


// Set up Jenkins security realm and authorization strategy

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(adminId, adminPassword)

instance.setSecurityRealm(hudsonRealm)


def strategy = new FullControlOnceLoggedInAuthorizationStrategy()

strategy.setAllowAnonymousRead(false)

instance.setAuthorizationStrategy(strategy)


// Set the Jenkins installation state to RUNNING to skip the setup wizard

def state = instance.getInstallState()

if (state != InstallState.RUNNING) {

    instance.setInstallState(InstallState.RUNNING)

}

def plugins = ["git", "workflow-aggregator", "pipeline-utility-steps", "github", "github-api", "configuration-as-code", "job-dsl", "github-branch-source", "multibranch-scan-webhook-trigger", "conventional-commits"]

def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()

println "--> Updating update center"
uc.updateAllSites()

println "--> Installing missing plugins"
plugins.each {
    if (!pm.getPlugin(it)) {
        def plugin = uc.getPlugin(it)
        if (plugin) {
            println "--> Installing plugin: $it"
            plugin.deploy()
        } else {
            println "--> Plugin $it not found in update center"
        }
    }
}

instance.save()
while (uc.isRestartRequiredForCompletion()) {
    println "-->Waiting for plugins to complete installation..."
    sleep(10000)  // Check every 10 seconds
}

// println "--> Preparing to restart Jenkins"
// // instance.safeRestart() // making sure restart happening after plugins installed.
// Jenkins.instance.doQuietDown() // Prevent new jobs from starting

// Thread.start {
//     println "-->Jenkins safe restart initiated."
//     while (true) {
//         if (Jenkins.instance.isQuietingDown()) {
//             if (RestartListener.isAllReady()) {
//                 println "-->All jobs completed. Restarting Jenkins now."
//                 Jenkins.instance.restart()
//                 break
//             }
//             println "-->Jobs still running. Retrying in 30 seconds..."
//             sleep(60000)  // Wait before retrying restart
//         } else {
//             println "-->Shutdown mode not enabled. Restart aborted."
//             break
//         }
//     }
// }

println 'A safe restart has been scheduled. Check Jenkins logs for updates.'