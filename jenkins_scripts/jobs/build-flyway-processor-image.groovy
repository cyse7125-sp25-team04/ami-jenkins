multibranchPipelineJob('build-flyway-processor-image') {
    branchSources {
        github {
            id('4')
            repoOwner('cyse7125-sp25-team04')
            repository('database-migration')
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
            token("database-migration")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}