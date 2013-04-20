require 'bitbucket_rest_api'
require 'date'

module BitbucketIssues
  class << self

    def config(config)
      @bitbucket = BitBucket.new basic_auth: "#{config[:username]}:#{config[:password]}"
      @owner = config[:repo_owner]
      @dropbox_folder = config[:dropbox_folder]
    end

    def issues(c, file_name = 'issues.html')
      config c

      total_issues = Array.new

      @bitbucket.repos.list do |repo|
        next unless repo.has_issues && repo.owner == @owner
        puts "checking issues inside #{repo.name}..."
        begin
          issues = @bitbucket.issues.list_repo(@owner, repo.name, { :filter => 'status=open' } )
          issues.each do |issue|
            issue[:utc_created_on] = Date.parse(issue.utc_created_on)
            issue[:project] = repo.name
            total_issues << issue
          end
        rescue BitBucket::Error::InternalServerError
          puts "stupid bitbucket. this repo has no issues"
        end
      end
      total_issues = total_issues.sort_by{ |k| k[:utc_created_on] }.reverse

      html = "<!DOCTYPE html>
      <html>

      <head>
      <style type='text/css'>
      table {border-collapse:collapse;}
      tr {padding:5px;}
      td {padding-right:5px; border-bottom:1px solid #fff;}
      span {font-size:120%;}
      </style>
      </head>

      <body>
      <center><span>BITBUCKET'S LATEST ISSUES</span></center><br>"
      html << "<table><th>project</th><th>from</th><th>kind</th><th>issue</th><th>responsible</th><th>priority</th>"
      total_issues.each do |issue|
        html << "<tr>"
        html << "<td align='center'>#{issue.project}</td>"
        html << "<td align='center'><img src='#{issue.reported_by.avatar}'></td>"
        html << "<td align='center'>#{issue.metadata.kind}</td>"
        html << "<td align='left'>#{issue.title}</td>"
        if issue.responsible?
          html << "<td align='center'><img src='#{issue.responsible.avatar}'></td>"
        else
          html << "<td align='center'>?</td>"
        end
        html << "<td align='center'>#{issue.priority}</td>"
        html << "</tr>"
      end
      html << "</table></body></html>"

      File.open("#{@dropbox_folder}/#{file_name}", "w") do |f|
        f.write html
      end
      puts "\nIssues inside the file #{@dropbox_folder}/#{file_name}"
    end
  end
end



