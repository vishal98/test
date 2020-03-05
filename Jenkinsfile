#!groovy

pipeline {
    agent any

    triggers { pollSCM('H/15 * * * *') }

    parameters {
        booleanParam(name: 'skip_destruction', defaultValue: true, description: 'Skip the destruction of the infrastructure')
        booleanParam(name: 'skip_tests', defaultValue: false, description: 'Skip the execution of the tests')
    }

    environment {
        AWS_ROLE = "ca_test_jenkins"
    }

    stages {
        stage('Setup') {

            steps {

                dir('scripts') {

                    sh 'python3 -m venv venv'
                    sh 'venv/bin/pip3 install -r requirements.txt'
                }
            }
        }
        stage('Infrastructure Creation') {
            environment {

                INFRA_ACTION = "apply"
            }
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'sample-dev', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'USER'),
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample' || env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 SSH_KEY=${SSH_KEY} LAYER=DEV venv/bin/python3 infra.py'
                        }
                    }
                }
            }
        }
        stage('Checkout and Sync') {
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample' || env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 LAYER=DEV venv/bin/python3 checkout_sync.py'

                        }
                    }
                }
            }
        }
        stage('Build') {
            environment {

                SOURCE_MARKET = 'UKN'
            }
            steps {
                withCredentials([string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample' || env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 LAYER=DEV SNOWFLAKE_SECRET_ID=ca-test-dev-snowflake-orchestration venv/bin/python3 build.py'

                        }
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'sample-dev', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'USER'),
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample'|| env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 SSH_KEY=${SSH_KEY} LAYER=DEV venv/bin/python3 deploy.py'
                        }
                    }
                }
            }
        }
        stage('Test') {
            when { expression { return params.skip_tests == false } }
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'sample-dev', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'USER'),
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample'|| env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 SSH_KEY=${SSH_KEY} LAYER=DEV venv/bin/python3 test.py'
                        }
                    }
                }
            }
        }
        stage('Infrastructure Destruction') {
            when { expression { return params.skip_destruction == false } }
            environment {

                INFRA_ACTION = "destroy"
            }
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'sample-dev', keyFileVariable: 'SSH_KEY', passphraseVariable: '', usernameVariable: 'USER'),
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample' || env.GIT_BRANCH.startsWith('origin/CYNG-'))
                                sh 'AWS_ACCOUNT_ID=awsacnt123 SSH_KEY=${SSH_KEY} LAYER=DEV venv/bin/python3 infra.py'
                        }
                    }
                }
            }
        }
        stage('Tag') {
            steps {
                withCredentials([
                        sshUserPrivateKey(credentialsId: 'test-service-user', keyFileVariable: 'GIT_SSH_KEY'),
                        string(credentialsId: 'test-orchestration-slack-webhook', variable: 'SLACK_WEBHOOK')
                ]) {

                    dir('scripts') {
                        script {

                            if (env.GIT_BRANCH == 'origin/sample')
                                sh 'LAYER=DEV venv/bin/python3 tag.py'
                        }
                    }
                }
            }
        }
    }//stages
    post {
        always {
            deleteDir() /* clean up our workspace */
        }
    }
}//pipeline