organizationFolder('pr-commit-validation-check.groovy') {
    description('Manages repositories and branches for the organization')
    
    organizations {
        github {
            apiUri('https://api.github.com')
            credentialsId('git-credentials')
            repoOwner('cyse7125-sp25-team04')
            
            traits {                
                // Include all branches/tags with wildcard
                sourceWildcardFilter  {
                    includes("*")
                    excludes("")
                }
            }
        }
    }

    configure { node ->
        node.remove(node / triggers)
        def webhookTrigger = node / triggers / 'com.igalg.jenkins.plugins.mswt.trigger.ComputedFolderWebHookTrigger' {
            spec('')  // No periodic scan, only webhook-based triggering
            token("pr-check") // Webhook token for authentication
        }
    }

    configure { node ->
        def githubNavigator = node / navigators / 'org.jenkinsci.plugins.github__branch__source.GitHubSCMNavigator' {
            repoOwner('cyse7125-sp25-team04') // GitHub organization or user
            apiUri('https://api.github.com') // GitHub API URL
            credentialsId('git-credentials') // Jenkins credential ID for GitHub authentication
            enableAvatar(true) // Enable repository avatars

            traits {
                // Discover pull requests from the origin repository
                'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
                    strategyId(2) // Strategy ID for merging PRs
                }

                // Discover pull requests from forks with specific trust settings
                'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
                    strategyId(2) // Strategy ID for merging forked PRs
                    trust(class: 'org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait$TrustPermission')
                }
            }
        }
    }

    configure { node ->
        def projectFactories = node / projectFactories / 'org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProjectFactory' {
            scriptPath("Jenkinsfile.pr")
        }
    }

}
