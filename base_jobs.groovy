
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
                        url("git@github.com:NorthfieldIT/jenkins-inspec-runner.git")
                        branch('master')
                    }
                }
            }
            steps {
                shell('bundle install')
                shell("inspec exec policies/* -t ssh://root@${node}  -i ~/.ssh/inspec_rsa")
            }
        }
    }
}




REPLACE_ME

