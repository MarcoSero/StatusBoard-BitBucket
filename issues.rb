$ParentDir = File.expand_path(File.dirname(__FILE__))

require $ParentDir + "/lib/bitbucket_issues.rb"

config = {
  username: 'username',
  password: 'password',
  repo_owner: 'you_or_your_company',
  dropbox_folder: '/Users/marcosero/Dropbox/sync'
}

# defaut filename: 'issues.html'
BitbucketIssues.issues config
