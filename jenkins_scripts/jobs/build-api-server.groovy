multibranchPipelineJob('build-api-server-images') {
    branchSources {
        github {
            id('4')
            repoOwner('cyse7125-sp25-team04')
            repository('api-server')
            buildForkPRHead(false)
            buildForkPRMerge(false)
            buildOriginBranchWithPR(false)
            buildOriginBranch(true)
            scanCredentialsId('git-credentials')
        }
    }
    configure { node ->
        def webhookTrigger = node / triggers / 'com.igalg.jenkins.plugins.mswt.trigger.ComputedFolderWebHookTrigger' {
            spec('')
            token("api-server")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}