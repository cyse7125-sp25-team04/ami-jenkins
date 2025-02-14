multibranchPipelineJob('static-site-image-build') {
    branchSources {
        github {
            id('2')
            repoOwner('cyse7125-sp25-team04')
            repository('static-site')
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
            token("static-site")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}