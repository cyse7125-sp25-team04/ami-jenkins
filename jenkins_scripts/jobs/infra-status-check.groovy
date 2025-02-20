multibranchPipelineJob('infra-gcp-status-check') {
    branchSources {
        github {
            id('1')
            repoOwner('cyse7125-sp25-team04')
            repository('tf-gcp-infra')
            buildForkPRHead(true)
            buildForkPRMerge(false)
            buildOriginBranchWithPR(false)
            buildOriginBranch(false)
            scanCredentialsId('git-credentials')
        }
    }
    configure { node ->
        def webhookTrigger = node / triggers / 'com.igalg.jenkins.plugins.mswt.trigger.ComputedFolderWebHookTrigger' {
            spec('')
            token("tf-gcp-infra-check")
        }
    }
    factory {
        workflowBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
}

organizationFolder('test-check') {
    description('Manages repositories and branches for the organization')
    
    organizations {
        github {
            apiUri('https://api.github.com')
            credentialsId('git-credentials')
            repoOwner('cyse7125-sp25-team04')
        }
    }
}


organizationFolder('test-check') {
    description('Manages repositories and branches for the organization')
    
    organizations {
        github {
            apiUri('https://api.github.com')
            credentialsId('git-credentials')
            repoOwner('cyse7125-sp25-team04')
            
            traits {
                // Discover branches
                
                // // Discover PRs from origin - current PR revision
                // originPullRequestDiscoveryTrait {
                //     strategyId(2) // Use current PR revision
                // }
                
                // // Discover PRs from forks - current PR revision
                // forkPullRequestDiscoveryTrait {
                //     strategyId(2) // Use current PR revision
                //     trust('contributors') // Trust only contributions from users with write permission
                // }
                
                // Include all branches/tags with wildcard
                sourceWildcardFilter  {
                    includes("*")
                    excludes("")
                }
            }
        }
    }
    
    // Configure webhook trigger instead of periodic scanning
    triggers {
        githubPushTrigger()
    }
    
    projectFactories {
        workflowMultiBranchProjectFactory {
            scriptPath('Jenkinsfile')
        }
    }
    
    // healthMetrics {
    //     worstChildHealthMetric()
    //     childrenOfflineMetric()
    // }
    
    // orphanedItemStrategy {
    //     discardOldItems {
    //         daysToKeep(7)
    //         numToKeep(10)
    //     }
    // }
}

organizationFolder('test-check') {
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
        def webhookTrigger = node / triggers / 'com.igalg.jenkins.plugins.mswt.trigger.ComputedFolderWebHookTrigger' {
            // spec('')  // No periodic scan, only webhook-based triggering
            token("tf-gcp-infra-check") // Webhook token for authentication
        }
    }

    // configure { node ->
    //     // Ensure the <triggers> section exists
    //     def triggers = node / triggers
    //     if (triggers) {
    //         // Find and remove the Periodic Folder Trigger
    //         triggers.children().findAll { it.name() == 'com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger' }.each {
    //             it.replaceNode {}
    //         }
    //     }
    // }

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
}