
class BaseBuildFramework {
    static complianceJob(dslFactory, node) {
        dslFactory.freeStyleJob("${node}_Compliance") {
            concurrentBuild()
            triggers {
                cron("H H * * *")
            }
            scm {
                git {
                    remote {
                        url("git@github.com:pragyav097/chef.git")
                        branch('main')
                    }
                }
            }
            steps {
                shell('bundle install')
                shell("inspec exec chef-demo/* -t ssh://root@${node}  -i ~/.ssh/inspec_rsa")
            }
        }
    }
}




REPLACE_ME

