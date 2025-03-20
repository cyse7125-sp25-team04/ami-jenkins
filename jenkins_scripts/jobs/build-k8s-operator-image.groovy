multibranchPipelineJob('build-k8s-operator-image') {
    branchSources {
        github {
            id('6')
            repoOwner('cyse7125-sp25-team04')
            repository('db-backup-operator')
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
            token("db-backup-operator")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}